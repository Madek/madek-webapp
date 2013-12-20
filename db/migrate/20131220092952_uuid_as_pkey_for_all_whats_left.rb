require Rails.root.join "db","migrate","uuid_migration_helper"
class UuidAsPkeyForAllWhatsLeft < ActiveRecord::Migration
  include ::UuidMigrationHelper

  def up


    # Grouppermissions
    prepare_table 'grouppermissions'
    migrate_table 'grouppermissions'

    # Userpermissions
    prepare_table 'userpermissions'
    migrate_table 'userpermissions'

    # arcs
    prepare_table :media_resource_arcs
    migrate_table :media_resource_arcs

    # media_files
    prepare_table :media_files
    migrate_foreign_key 'previews', 'media_files'
    migrate_foreign_key 'zencoder_jobs', 'media_files'
    migrate_table :media_files
    add_foreign_key 'previews', 'media_files'
    add_foreign_key 'zencoder_jobs', 'media_files', dependent: :delete

    # edit sessions
    prepare_table 'edit_sessions'
    migrate_table 'edit_sessions'

    prepare_table 'keywords'
    migrate_table 'keywords'

    prepare_table 'meta_key_definitions'
    migrate_table 'meta_key_definitions'

    prepare_table 'permission_presets'
    migrate_table 'permission_presets'

    prepare_table 'previews'
    migrate_table 'previews'

    prepare_table 'usage_terms'
    migrate_table 'usage_terms'

  end


end
