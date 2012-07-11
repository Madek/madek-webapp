module MigrationHelpers
  module MetaDatum
    class << self

      ############ Date ########################################
      def migrate_meta_date raw_meta_datum
        obj = YAML.load raw_meta_datum.value.gsub /^-\s+.*\n/, ""
        new_string_value=  
          if obj.is_a? Hash
            obj.try(:fetch,"free_text").try(:strip)
          else
            ""
          end
        raw_meta_datum.update_attributes string: new_string_value
      end

      def migrate_meta_dates
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaDate'")
          .where("type is NULL or type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          migrate_meta_date rmd
          rmd.update_column :type, "MetaDatumDate"
        end

        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumDate'},
                           {object_type: 'MetaDate'})
      end
    end
  end
end


class MigrateMetaDatesData < ActiveRecord::Migration

  def up
    MigrationHelpers::MetaDatum.migrate_meta_dates
  end

  def down
    # raise "this is a irreversible migration"
  end

end
