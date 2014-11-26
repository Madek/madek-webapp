class MigrateFavoriteCollections < ActiveRecord::Migration

  def change

    reversible do |dir|
      dir.up do

        execute %{

          INSERT INTO favorite_collections (user_id, collection_id)
          SELECT favorites.user_id, favorites.media_resource_id
          FROM favorites
          INNER JOIN media_resources
          ON favorites.media_resource_id = media_resources.id
          WHERE media_resources.type = 'MediaSet';

        }

      end
    end

  end

end
