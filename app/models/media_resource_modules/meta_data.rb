# -*- encoding : utf-8 -*-
#
module MediaResourceModules
  module MetaData
    def self.included(base)
      base.class_eval do 


       # TODO observe bulk changes and reindex once
        has_many :meta_data, :dependent => :destroy do #working here#7 :include => :meta_key
          def get(key_id, build_if_not_found = true)
            #TODO: handle the case when key_id is a MetaKey object
            key_id = MetaKey.find_by_label(key_id.downcase).id unless key_id.is_a?(Fixnum)
            r = where(:meta_key_id => key_id).first # OPTIMIZE prevent find if is_dynamic meta_key
            r ||= build(:meta_key_id => key_id) if build_if_not_found
            r
          end

          def get_value_for(key_id)
            get(key_id).to_s
          end

          def get_for_labels(labels)
            joins(:meta_key).where(:meta_keys => {:label => labels})
          end

          #def with_labels
          #  h = {}
          #  all.each do |meta_datum|
          #    next unless meta_datum.meta_key # FIXME inconsistency: there are meta_data referencing to not existing meta_key_ids [131, 135]
          #    h[meta_datum.meta_key.label] = meta_datum.to_s
          #  end
          #  h
          #end
          def concatenated
            all.map(&:to_s).join('; ')
          end
        end


        accepts_nested_attributes_for :meta_data, :allow_destroy => true,
          :reject_if => proc { |attributes| attributes['value'].blank? and attributes['_destroy'].blank? }
        # NOTE the check on _destroy should be automatic, check Rails > 3.0.3

        # TODO remove, it's used only on tests!
        def self.find_by_title(title)
          MediaResource.joins(:meta_data => :meta_key).where(:meta_keys => {:label => "title"}, :meta_data => {:string => title})
        end

        def title
          t = meta_data.get_value_for("title")
          t = "Ohne Titel" if t.blank?
          t
        end

        def title_and_user
          s = ""
          s += "#{title} (#{user})"
        end


        def update_attributes_with_pre_validation(attributes, current_user = nil)
          # we need to deep copy the attributes for batch edit (multiple resources)
          dup_attributes = Marshal.load(Marshal.dump(attributes)).deep_symbolize_keys

          if dup_attributes[:meta_data_attributes]
            # To avoid overriding at batch update: remove from attribute hash if :keep_original_value and value is blank
            dup_attributes[:meta_data_attributes].delete_if { |key, attr| attr[:keep_original_value] and attr[:value].blank? }

            dup_attributes[:meta_data_attributes].each_pair do |key, attr|
              if attr[:value].is_a? Array and attr[:value].all? {|x| x.blank? }
                attr[:value] = nil
              end

              # find existing meta_datum, if it exists
              if attr[:id].blank?
                if attr[:meta_key_label]
                  attr[:meta_key_id] ||= MetaKey.find_by_label(attr.delete(:meta_key_label)).try(:id)
                end
                if (md = meta_data.where(:meta_key_id => attr[:meta_key_id]).first)
                  attr[:id] = md.id
                end
              else
                attr.delete(:meta_key_label)
              end

              # get rid of meta_datum if value is blank
              if !attr[:id].blank? and attr[:value].blank?
                attr[:_destroy] = true
                #old# attr[:value] = "." # NOTE bypass the validation
              end
            end
          end

          self.editors << current_user if current_user # OPTIMIZE group by user ??
          self.updated_at = Time.now # OPTIMIZE touch
          update_attributes_without_pre_validation(dup_attributes)
        end


        ########################################################

        def meta_data_for_context(context = MetaContext.core, build_if_not_exists = true)

          meta_keys = context.meta_keys

          mds = meta_data.where(:meta_key_id => meta_keys)

          (meta_keys - mds.map(&:meta_key)).select{|x| x.is_dynamic? }.each do |key|
            mds << meta_data.build(:meta_key => key) 
          end

          (context.meta_key_ids - mds.map(&:meta_key_id)).each do |key_id|
            mds << meta_data.build(:meta_key_id => key_id)
          end if build_if_not_exists

          mds.sort_by {|md| context.meta_key_ids.index(md.meta_key_id) } 
        end

        def context_warnings(context = MetaContext.core)
          r = {}

          meta_data_for_context(context).each do |meta_datum|
            w = meta_datum.context_warnings(context)
            unless w.blank?
              r[meta_datum.meta_key.label] ||= []
              r[meta_datum.meta_key.label] << w
            end
          end

          r
        end

        def context_valid?(context = MetaContext.core)
          meta_data_for_context(context).all? {|meta_datum| meta_datum.context_valid?(context) }
        end




      end
    end
  end
end


