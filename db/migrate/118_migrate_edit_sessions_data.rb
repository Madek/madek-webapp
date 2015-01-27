class MigrateEditSessionsData < ActiveRecord::Migration

  private

  def copy_ids(for_type, to_column)
    execute "
      UPDATE edit_sessions
      SET #{to_column} = r.id
      FROM (
        SELECT id
        FROM media_resources
        WHERE type = '#{for_type}' ) AS r
      WHERE media_resource_id = r.id
    "
  end

  public

  def change
    reversible do |dir|
      dir.up do

        copy_ids 'MediaEntry', 'media_entry_id'
        copy_ids 'MediaEntryIncomplete', 'media_entry_id'
        copy_ids 'MediaSet',  'collection_id'
        copy_ids 'FilterSet', 'filter_set_id'

      end
    end

    remove_column :edit_sessions, :media_resource_id, :uuid
  end
end
