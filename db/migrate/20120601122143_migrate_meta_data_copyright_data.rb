module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_copyrights
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'Copyright'")
          .where("type is NULL OR type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, "MetaDatumCopyright"
          rmd.update_column :copyright_id, YAML.load(rmd.value)[0]
        end

        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumCopyright'},
                           {object_type: 'Copyright'})

      end

    end
  end
end


class MigrateMetaDataCopyrightData < ActiveRecord::Migration

  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_copyrights
  end

  def down
  end

end
