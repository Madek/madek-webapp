class DropMediaSetsQueryColumn < ActiveRecord::Migration
  def up
    remove_column :media_sets, :query
  end

  def down
    change_table :media_sets do |t|
      t.string :query
    end
  end
end
