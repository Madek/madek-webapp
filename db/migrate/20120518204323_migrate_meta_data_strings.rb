module MigrationHelpers
  module MetaDatum
    class << self

      ############ String ########################################

      def migrate_meta_strings
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaCountry' OR meta_keys.object_type is NULL")
          .where("type is NULL or type = 'MetaDatum' ")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_attributes string: YAML.load(rmd.value)
          rmd.update_column :type, "MetaDatumString"
        end

        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumString'},
                           "object_type is NULL OR object_type = 'MetaCountry'")
      end

    end
  end
end

class MigrateMetaDataStrings < ActiveRecord::Migration

  def up
    MigrationHelpers::MetaDatum.migrate_meta_strings
  end

  def down
    # raise "this is a irreversible migration"
  end


end
