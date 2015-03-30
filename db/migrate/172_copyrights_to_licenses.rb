require Rails.root.join("db","migrate","migration_helper.rb")
class CopyrightsToLicenses < ActiveRecord::Migration
  include MigrationHelper

  def change
    #remove_foreign_key :meta_data, :copyrights
    remove_column :copyrights, :parent_id
    rename_table :copyrights, :licenses 

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

  end
end
