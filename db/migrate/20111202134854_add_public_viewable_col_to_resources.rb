class AddPublicViewableColToResources < ActiveRecord::Migration
  def change
    add_column :media_entries, :perm_public_may_view, :boolean, :default => false
    add_column :media_entries, :perm_public_may_download, :boolean, :default => false
    add_column :media_sets, :perm_public_may_view, :boolean, :default => false
    add_column :media_sets, :perm_public_may_download, :boolean, :default => false
  end
end
