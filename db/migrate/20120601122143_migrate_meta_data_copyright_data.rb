module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_copyright rmd
        mdp = MetaDatumCopyright.find rmd.id
        mdp.update_attributes copyright: Copyright.find(YAML.load(rmd.value)[0])
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_datum_copyrights
      
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'Copyright'")
          .where("type is NULL OR type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, "MetaDatumCopyright"
          migrate_meta_datum_copyright rmd
        end

        MetaKey.where("object_type = 'Copyright'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumCopyright'
        end

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
