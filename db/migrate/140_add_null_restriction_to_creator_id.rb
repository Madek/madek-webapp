class AddNullRestrictionToCreatorId < ActiveRecord::Migration
  def change
    change_column :media_entries, :creator_id, :uuid, null: false
  end
end
