require Rails.root.join 'db', 'migrate', 'media_resource_migration_models'

class MigrateMetaDataLicenses < ActiveRecord::Migration
  include MigrationHelper
  include MediaResourceMigrationModels

  def change
    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      ::MigrationMetaDatumLicense.all.group_by(&:media_entry_id).each do |meta_data_bundle|
        media_entry_id = meta_data_bundle.first
        meta_data = meta_data_bundle.second

        meta_data.group_by(&:meta_key_id).each do |meta_data_bundle|
          meta_key_id = meta_data_bundle.first
          # uniq for the case that there are several meta data
          # for the same media entry and license
          meta_data = meta_data_bundle.second.uniq(&:license_id)
          meta_datum_to_keep = meta_data.first

          meta_data.each do |meta_datum|
            ::MigrationMetaDataLicenses.create!(meta_datum_id: meta_datum_to_keep.id,
                                                license_id: meta_datum.license.id)
          end

          meta_data.select { |md| not md.id == meta_datum_to_keep.id }.each(&:delete)

          unless single_meta_datum?(media_entry_id, meta_key_id)
            raise 'Multiple meta_data for meta_key and media_resource_id'
          end
        end
      end

      ::MigrationMetaDatumLicense.update_all type: 'MetaDatum::Licenses'

      execute "SET session_replication_role = DEFAULT"
    end

    remove_column :meta_data, :license_id
  end

  private

  def single_meta_datum?(media_entry_id, meta_key_id)
    ::MigrationMetaDatumLicense
      .where(media_entry_id: media_entry_id,
             meta_key_id: meta_key_id)
      .count == 1
  end
end
