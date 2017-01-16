class AddItemIdToAttachments < ActiveRecord::Migration
  def up
    add_column :attachments, :item_id, :uuid, index: true
    add_foreign_key :attachments, :items, on_delete: :cascade
  end
end
