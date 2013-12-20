require Rails.root.join "db","migrate","uuid_migration_helper"

class UuidAsPkeyForMetaEverything < ActiveRecord::Migration

  include ::UuidMigrationHelper

  def up

    #
    # meta_keys_meta_terms
    #
     
    prepare_table 'meta_keys_meta_terms'
    migrate_table 'meta_keys_meta_terms'


    #
    # meta_context_groups
    #

    prepare_table 'meta_context_groups'
    migrate_foreign_key 'meta_contexts', 'meta_context_groups', true
    migrate_table 'meta_context_groups'
    add_foreign_key 'meta_contexts', 'meta_context_groups', options: 'ON DELETE SET NULL' 


    #
    # meta_data
    #

    prepare_table 'meta_data'

    migrate_foreign_key 'meta_data_meta_terms', 'meta_data'
    migrate_foreign_key 'keywords', 'meta_data'
    migrate_foreign_key 'meta_data_people', 'meta_data'
    migrate_foreign_key 'meta_data_users', 'meta_data'
    migrate_foreign_key 'meta_data_meta_departments', 'meta_data'

    migrate_table 'meta_data'

    add_foreign_key 'meta_data_meta_terms', 'meta_data', dependent: :delete
    add_foreign_key 'keywords', 'meta_data', dependent: :delete
    add_foreign_key 'meta_data_people', 'meta_data', dependent: :delete
    add_foreign_key 'meta_data_users', 'meta_data', dependent: :delete
    add_foreign_key 'meta_data_meta_departments', 'meta_data', dependent: :delete

    add_index :meta_data_meta_terms, [:meta_datum_id, :meta_term_id], unique: true
    add_index :meta_data_people, [:meta_datum_id, :person_id], unique: true
    add_index :meta_data_users, [:meta_datum_id, :user_id], unique: true
    add_index :meta_data_meta_departments, [:meta_datum_id, :meta_department_id], \
      unique: true, name: 'index_meta_data_meta_dep_on_meta_datum_id_and_meta_dep_id'

    #
    # meta_terms
    #

    prepare_table 'meta_terms'

    migrate_foreign_key 'keywords', 'meta_terms'
    migrate_foreign_key 'meta_contexts', 'meta_terms', false, 'label_id'
    migrate_foreign_key 'meta_contexts', 'meta_terms', true, 'description_id'
    migrate_foreign_key 'meta_data_meta_terms', 'meta_terms'
    migrate_foreign_key 'meta_key_definitions', 'meta_terms', true, 'description_id'
    migrate_foreign_key 'meta_key_definitions', 'meta_terms', true, 'hint_id'
    migrate_foreign_key 'meta_key_definitions', 'meta_terms', true, 'label_id'
    migrate_foreign_key 'meta_keys_meta_terms', 'meta_terms'

    migrate_table 'meta_terms'

    add_foreign_key 'keywords', 'meta_terms', dependent: :delete
    add_foreign_key 'meta_contexts', 'meta_terms', column: 'description_id', options: 'ON DELETE SET NULL'
    add_foreign_key 'meta_contexts', 'meta_terms', column: 'label_id'
    add_foreign_key 'meta_data_meta_terms', 'meta_terms', dependent: :delete
    add_foreign_key 'meta_key_definitions', 'meta_terms', column: 'description_id', options: 'ON DELETE SET NULL'
    add_foreign_key 'meta_key_definitions', 'meta_terms', column: 'hint_id', options: 'ON DELETE SET NULL'
    add_foreign_key 'meta_key_definitions', 'meta_terms', column: 'label_id', options: 'ON DELETE SET NULL' 
    add_foreign_key 'meta_keys_meta_terms', 'meta_terms'


    #
    # copyrights
    #

    prepare_table 'copyrights'
    migrate_foreign_key 'meta_data', 'copyrights', true
    add_column :copyrights, :parent_uuid, :uuid
    execute %[ UPDATE copyrights 
                SET parent_uuid = cp.uuid 
                FROM copyrights as cp
                WHERE copyrights.parent_id = cp.parent_id] 
    remove_column :copyrights, :parent_id
    rename_column :copyrights, :parent_uuid, :parent_id
    migrate_table 'copyrights'
    add_foreign_key :copyrights, :copyrights, column: :parent_id
    add_foreign_key 'meta_data', 'copyrights'

  end
end
