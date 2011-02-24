# -*- encoding : utf-8 -*-
class Admin::MetaController < Admin::AdminController

  def import
    @buffer = []
    if request.post? and params[:uploaded_data]
      ActiveRecord::Base.transaction do
        ###################################################
        # collect existing meta_data references
        @meta_data = {}
        MetaDatum.all.each do |meta_datum|
          @meta_data[meta_datum.id] = { :meta_key_label => meta_datum.meta_key.label } 
  
          # OPTIMIZE
          case meta_datum.meta_key.object_type
            when "Meta::Term", "Meta::Date" 
              if meta_datum.value.empty?
                meta_datum.destroy
                next
              end
              if meta_datum.meta_key.object_type == "Meta::Term"
                @meta_data[meta_datum.id][:meta_terms] = Meta::Term.find(meta_datum.value).collect do |term|
                  b = {}
                  LANGUAGES.each do |lang|
                    s = term.send(lang)
                    b[lang] = s unless s.blank? 
                  end
                  b
                end
              end
          end
          
        end
        
        MetaDatum.update_all("meta_key_id = (meta_key_id * -1)")
  
        ###################################################
        # core meta import
        meta = YAML.load(params[:uploaded_data])
        
        if meta[:meta_terms] and meta[:meta_keys] and meta[:meta_contexts] and meta[:meta_key_definitions]   
    
          [MetaKey, MetaContext, MetaKeyDefinition, Meta::Term, UsageTerm].each {|a| a.destroy_all }
    
          meta[:meta_terms].each do |term|
            k = Meta::Term.new(term)
            k.id = term["id"]
            k.save
#            @buffer << k.inspect
          end
    
          meta[:meta_keys].each do |meta_key|
            meta_terms = meta_key.delete("meta_terms")
            k = MetaKey.new(meta_key)
            k.id = meta_key["id"]
            k.save
            k.meta_terms << Meta::Term.find(meta_terms) if meta_terms
#            @buffer << k.inspect
          end
    
          meta[:meta_contexts].each do |meta_context|
            k = MetaContext.new(meta_context)
            k.id = meta_context["id"]
            k.save
#            @buffer << k.inspect
          end
    
          meta[:meta_key_definitions].each do |meta_key_definition|
            k = MetaKeyDefinition.new(meta_key_definition)
            k.id = meta_key_definition["id"]
            k.save
#            @buffer << k.inspect
          end

          k = UsageTerm.new(meta[:usage_terms])
          k.id = meta[:usage_terms]["id"]
          k.save
        end
  
        ###################################################
        # re-reference existing meta_data
  
#        @buffer << @meta_data.inspect
#        @buffer << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

        @meta_keys = {}
        MetaDatum.where("meta_key_id < 0").each do |meta_datum|
          k = @meta_keys[@meta_data[meta_datum.id][:meta_key_label]] ||= MetaKey.find_by_label(@meta_data[meta_datum.id][:meta_key_label])
          meta_datum.meta_key = k

          if k.object_type == "Meta::Term"
            meta_datum.value = if @meta_data[meta_datum.id][:meta_terms]
              @meta_data[meta_datum.id][:meta_terms].map {|h| k.meta_terms.where(h).first.try(:id) }
            else
              # OPTIMIZE 2210 search as OR condition
              conditions = {}
              LANGUAGES.each do |lang|
                conditions[lang] = meta_datum.value   
              end
              k.meta_terms.where(conditions).first
            end.compact
          end

          unless meta_datum.save
            @buffer << meta_datum.inspect
            @buffer << meta_datum.errors.full_messages
            @buffer << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            break
          end
        end
  
        negatives = MetaDatum.where("meta_key_id < 0").count
        if negatives > 0
          @buffer << "--- ERROR: %d meta_data aren't correctly restored ---" % negatives
          ActiveRecord::Base.connection.rollback_db_transaction
          @buffer << "--- The import has been aborted with rollback ---"
        else
          @buffer << `rake ts:reindex`
          @buffer << "--- Import completed successfully ---"
        end
        
      end
    end
  end

  def export
      h = {}

      h[:meta_terms] = Meta::Term.all.collect(&:attributes)

      h[:meta_keys] = MetaKey.all.collect do |meta_key|
        a = meta_key.attributes
        a["meta_terms"] = meta_key.meta_terms.collect(&:id) if meta_key.object_type == "Meta::Term"
        a
      end

      h[:meta_contexts] = MetaContext.all.collect do |meta_contexts|
        a = {}
        ["id", "name", "is_user_interface"].each do |b|
          v = meta_contexts.send(b)
          a[b] = v unless v.blank?
        end
        a["meta_field"] = meta_contexts.meta_field.instance_values
        a
      end

      h[:meta_key_definitions] = MetaKeyDefinition.all.collect do |meta_key_definition|
        a = {}
        ["id", "meta_key_id", "meta_context_id", "position", "key_map", "key_map_type"].each do |b|
          v = meta_key_definition.send(b)
          a[b] = v unless v.blank?
        end
        a["meta_field"] = meta_key_definition.meta_field.instance_values
        a
      end

#future#
#      h[:copyrights] = Copyright.all.collect(&:attributes)

      h[:usage_terms] = UsageTerm.current.attributes

      send_data h.to_yaml, :filename => "meta.yml", :type => :yaml
  end

end
