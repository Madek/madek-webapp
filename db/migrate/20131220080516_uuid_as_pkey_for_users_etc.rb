require Rails.root.join "db","migrate","uuid_migration_helper"

class UuidAsPkeyForUsersEtc < ActiveRecord::Migration

  include ::UuidMigrationHelper

  def up


    #
    # Groups
    #

    prepare_table 'groups'
    migrate_foreign_key 'grouppermissions', 'groups'
    migrate_foreign_key 'groups_users', 'groups'
    migrate_foreign_key 'meta_data_meta_departments', 'groups', false, 'meta_department_id'
    migrate_table 'groups'
    add_foreign_key 'grouppermissions', 'groups', dependent: :delete
    add_foreign_key 'groups_users', 'groups', dependent: :delete
    add_foreign_key 'meta_data_meta_departments', 'groups', column: 'meta_department_id', dependent: :delete
    add_index :groups_users, [:group_id,:user_id], unique: true


    #
    # Users
    #

    execute %< DELETE FROM visualizations >

    prepare_table 'users'

    migrate_foreign_key 'edit_sessions', 'users'
    migrate_foreign_key 'favorites', 'users'
    migrate_foreign_key 'groups_users', 'users'
    migrate_foreign_key 'keywords', 'users', true
    migrate_foreign_key 'media_resources', 'users'
    migrate_foreign_key 'meta_data_users', 'users'
    migrate_foreign_key 'userpermissions', 'users'
    migrate_foreign_key 'visualizations', 'users'

    migrate_table 'users'

    add_foreign_key 'edit_sessions', 'users', dependent: :delete
    add_foreign_key 'favorites', 'users', dependent: :delete
    add_foreign_key 'groups_users', 'users', dependent: :delete
    add_foreign_key 'keywords', 'users'
    add_foreign_key 'media_resources', 'users'
    add_foreign_key 'meta_data_users', 'users', dependent: :delete
    add_foreign_key 'userpermissions', 'users', dependent: :delete
    add_foreign_key 'visualizations', 'users', dependent: :delete

    add_index :visualizations, [:user_id,:resource_identifier], unique: true


    #
    # PEOPLE 
    #

    prepare_table 'people'
    migrate_foreign_key 'users', 'people'
    migrate_foreign_key 'meta_data_people', 'people'
    add_index 'meta_data_people', [:meta_datum_id,:person_id], unique: true
    migrate_table 'people'
    add_foreign_key 'users','people'
    add_foreign_key 'meta_data_people', 'people'


  end

end
