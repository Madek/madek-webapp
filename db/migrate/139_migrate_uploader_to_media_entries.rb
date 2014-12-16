class MigrateUploaderToMediaEntries < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do

        execute %(
          UPDATE media_entries AS me
          SET creator_id = r.user_id
          FROM (
            SELECT user_id, media_entry_id
            FROM meta_data_users AS mdu
            INNER JOIN meta_data AS md
            ON md.id = mdu.meta_datum_id
            WHERE md.meta_key_id = 'uploaded by' ) AS r
          WHERE r.media_entry_id = me.id;
        )

        # media_entries.responsible_user_id as fallback for media_entries with creator_id == NULL
        execute %(
          UPDATE media_entries
          SET creator_id = responsible_user_id
          WHERE creator_id is null;
        )

      end
    end
  end
end
