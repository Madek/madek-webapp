class MigrateEditSessionsData < ActiveRecord::Migration

  private

  def copy_ids for_type:, to_column:

    execute %Q(
      UPDATE edit_sessions
      SET #{to_column} = r.id
      FROM (
        SELECT id
        FROM media_resources
        WHERE type = '#{for_type}' ) AS r
      WHERE media_resource_id = r.id
    )

  end

  public

  def change

    reversible do |dir|
      dir.up do

        copy_ids for_type: "MediaEntry", to_column: "media_entry_id"
        copy_ids for_type: "MediaSet", to_column: "collection_id"
        copy_ids for_type: "FilterSet", to_column: "filter_set_id"

      end
    end

    remove_column :edit_sessions, :media_resource_id, :uuid

  end
end
