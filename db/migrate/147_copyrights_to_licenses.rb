require Rails.root.join("db","migrate","migration_helper.rb")
class CopyrightsToLicenses < ActiveRecord::Migration
  include MigrationHelper

  class License < ActiveRecord::Base
  end

  class MetaDatum < ActiveRecord::Base
    self.inheritance_column = nil
    belongs_to :license
  end


  def change
    #remove_foreign_key :meta_data, :copyrights
    remove_column :copyrights, :parent_id
    rename_table :copyrights, :licenses 
    rename_column :meta_data, :copyright_id, :license_id

    create_table :license_groups, id: :uuid do |t|
      t.text :name, null: false
      t.text :description
      t.float :position
      t.uuid :parent_id 
    end
    add_timestamps :license_groups

    execute 'ALTER TABLE license_groups ADD CONSTRAINT parent_id_fkey FOREIGN KEY (parent_id) REFERENCES license_groups (id)'

    create_table :licenses_license_groups, id: false do |t|
      t.uuid :license_id 
      t.uuid :license_group_id 
    end
    add_timestamps :licenses_license_groups

    add_foreign_key :licenses_license_groups, :licenses
    add_foreign_key :licenses_license_groups, :license_groups

    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      execute "UPDATE meta_data" \
        " SET meta_key_id = 'license', type = 'MetaDatum::License'" \
        " WHERE meta_key_id = 'copyright status'"

      execute "UPDATE meta_keys " \
        " SET id = 'license', meta_datum_object_type = 'MetaDatum::License'" \
        " WHERE id = 'copyright status'"

      execute "UPDATE meta_key_definitions "\
        " SET meta_key_id = 'license' "\
        " WHERE meta_key_id = 'copyright status'"

      MetaDatum.where(meta_key_id: 'copyright url').find_each do |copyright_url|
        license= License.find_or_create_by url: copyright_url.string, label: copyright_url.string

        copyright_url.update_attributes!  \
          license_id: license.id,
          type: 'MetaDatum::License', 
          string: nil,
          meta_key_id: 'license'

      end

      execute "SET session_replication_role = DEFAULT"
    end

    # raise "NOT YET"

  end
end
