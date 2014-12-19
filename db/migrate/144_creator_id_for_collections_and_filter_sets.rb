class CreatorIdForCollectionsAndFilterSets < ActiveRecord::Migration
  def change
    # collections.responsible_user_id as fallback for collections with creator_id == NULL
    execute %(
      UPDATE collections
      SET creator_id = responsible_user_id
      WHERE creator_id IS NULL
    )

    change_column :collections, :creator_id, :uuid, null: false

    # filter_set.responsible_user_id as fallback for filter_sets with creator_id == NULL
    execute %(
      UPDATE filter_sets
      SET creator_id = responsible_user_id
      WHERE creator_id IS NULL
    )

    change_column :filter_sets, :creator_id, :uuid, null: false
  end
end
