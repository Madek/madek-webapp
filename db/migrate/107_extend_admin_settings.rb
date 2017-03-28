class ExtendAdminSettings < ActiveRecord::Migration
  def change
    add_column :settings, :external_base_url, :string
    add_column :settings, :custom_head_tag, :text
  end
end
