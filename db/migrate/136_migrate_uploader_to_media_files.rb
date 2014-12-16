class MigrateUploaderToMediaFiles < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do

        execute %(
          UPDATE media_files AS mf
          SET uploader_id = r.user_id
          FROM (
            SELECT user_id, media_entry_id
            FROM meta_data_users AS mdu
            INNER JOIN meta_data AS md
            ON md.id = mdu.meta_datum_id
            WHERE md.meta_key_id = 'uploaded by' ) AS r
          WHERE r.media_entry_id = mf.media_entry_id;
        )

        # media_entries.responsible_user_id as fallback for media_files with uploader_id == NULL
        execute %(
          UPDATE media_files AS mf
          SET uploader_id = me.responsible_user_id
          FROM media_entries AS me
          WHERE mf.media_entry_id = me.id
          AND mf.uploader_id is null;
        )

      end
    end
  end
end
