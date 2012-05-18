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


    end

  end
end


