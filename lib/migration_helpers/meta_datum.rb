module MigrationHelpers

  module MetaDatum

    class RawMetaDatum < ActiveRecord::Base 
      set_table_name :meta_data
      belongs_to :meta_key
    end

    class << self

      def migrate_meta_string raw_meta_datum
        s = YAML.load raw_meta_datum.value
        raw_meta_datum.update_attributes ({ 
          string: s, 
          value: nil
        })
        raw_meta_datum.update_column :type, "MetaDatumString"
      end


      def migrate_meta_strings

        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaCountry' OR meta_keys.object_type is NULL")
          .where("type is NULL")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          migrate_meta_string rmd
        end

        MetaKey.where("object_type = 'MetaCountry'").each do |mk|
          mk.update_attributes object_type: nil
        end

      end


      def migrate_meta_date raw_meta_datum
        obj = YAML.load raw_meta_datum.value.gsub /^-\s+.*\n/, ""
        new_string_value=  
          if obj.is_a? Hash
            obj.try(:fetch,"free_text").try(:strip)
          else
            ""
          end
        raw_meta_datum.update_attributes ({ 
          string: new_string_value, 
          value: nil
        })
        raw_meta_datum.update_column :type, "MetaDatumDate"
      end

      def migrate_meta_dates

        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaDate'")
          .where("type is NULL")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          migrate_meta_date rmd
        end

        MetaKey.where("object_type = 'MetaDate'").each do |mk|
          mk.update_attributes object_type: nil
        end

      end


      def migrate_meta_person
      end

      def migrate_meta_people
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'Person'")
          .where("type is NULL")
      end

    end
  end
end
