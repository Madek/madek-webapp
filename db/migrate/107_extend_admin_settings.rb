class ExtendAdminSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :external_base_url, :string
    add_column :settings, :custom_head_tag, :text
  end
end
