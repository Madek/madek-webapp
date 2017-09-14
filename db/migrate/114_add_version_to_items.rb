class AddVersionToItems < ActiveRecord::Migration[4.2]

  def up
    add_column :items, :item_version, :string
  end
end
