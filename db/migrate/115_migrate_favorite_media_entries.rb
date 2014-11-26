class MigrateFavoriteMediaEntries < ActiveRecord::Migration

  def change

    reversible do |dir|
      dir.up do

        execute %{

          INSERT INTO favorite_media_entries (user_id, media_entry_id)
          SELECT favorites.user_id, favorites.media_resource_id
          FROM favorites
          INNER JOIN media_resources
          ON favorites.media_resource_id = media_resources.id
          WHERE media_resources.type = 'MediaEntry';

        }

      end
    end

  end

end
