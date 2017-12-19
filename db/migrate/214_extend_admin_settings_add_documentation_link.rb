class ExtendAdminSettingsAddDocumentationLink < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :documentation_link, :string, default: ''
  end
end
