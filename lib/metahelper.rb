module MetaHelper 

  def self.import_initial_metadata(uploaded_data=nil)

    # TODO cleanup and remove from admin meta controller

    buffer = []
    begin
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

        MetaDatum.reset_column_information
        MetaDatum.update_all("meta_key_id = (meta_key_id * -1)")

        ###################################################
        # core meta import
        uploaded_data ||= File.read("#{Rails.root}/features/data/minimal_meta.yml")
        meta = YAML.load(uploaded_data)

        #binding.pry

        if meta[:meta_terms] and meta[:meta_keys] and meta[:meta_contexts] and meta[:meta_key_definitions]   

          [MetaKey, MetaContext, MetaKeyDefinition, Meta::Term, UsageTerm].each {|a| a.destroy_all }

          meta[:meta_terms].each do |term|
            k = Meta::Term.new(term)
            k.id = term["id"]
            k.save
            #            buffer << k.inspect
          end

          meta[:meta_keys].each do |meta_key|
            meta_terms = meta_key.delete("meta_terms")
            k = MetaKey.new(meta_key)
            k.id = meta_key["id"]
            k.save
            k.meta_terms << Meta::Term.find(meta_terms) if meta_terms
            #            buffer << k.inspect
          end

          meta[:meta_contexts].each do |meta_context|
            k = MetaContext.new(meta_context)
            k.id = meta_context["id"]
            k.save
            #            buffer << k.inspect
          end

          meta[:meta_key_definitions].each do |meta_key_definition|
            k = MetaKeyDefinition.new(meta_key_definition)
            k.id = meta_key_definition["id"]
            k.save
            #            buffer << k.inspect
          end

          k = UsageTerm.new(meta[:usage_terms])
          k.id = meta[:usage_terms]["id"]
          k.save
        end

        ###################################################
        # re-reference existing meta_data

        #        buffer << @meta_data.inspect
        #        buffer << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

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
            buffer << meta_datum.inspect
            buffer << meta_datum.errors.full_messages
            buffer << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            break
          end
        end

        negatives = MetaDatum.where("meta_key_id < 0").count
        if negatives > 0
          buffer << "--- ERROR: %d meta_data aren't correctly restored ---" % negatives
          ActiveRecord::Base.connection.rollback_db_transaction
          buffer << "--- The import has been aborted with rollback ---"
        else
          # Sphinx is not needed anymore
          #buffer << `rake ts:reindex`
          buffer << "--- Import completed successfully ---"
        end
      end
    rescue 
      buffer << $!
    end
    buffer
  end
end
