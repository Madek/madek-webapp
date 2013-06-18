class AddDisplayedMetaContextsToAppSettings < ActiveRecord::Migration
  def up
    add_column :app_settings, :second_displayed_meta_context_name, :string
    add_foreign_key :app_settings, :meta_contexts,column: :second_displayed_meta_context_name, primary_key: 'name'
    add_column :app_settings, :third_displayed_meta_context_name, :string
    add_foreign_key :app_settings, :meta_contexts,column: :third_displayed_meta_context_name, primary_key: 'name'
  end

  def down
    remove_column :app_settings, :second_displayed_meta_context_name
    remove_column :app_settings, :third_displayed_meta_context_name
  end
end
