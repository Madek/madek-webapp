class RefactorMetaContexts < ActiveRecord::Migration
  def change
    rename_table :meta_contexts, :contexts
    rename_column :contexts, :name, :id
    rename_column :contexts, :meta_context_group_id, :context_group_id
    rename_table :meta_context_groups, :context_groups
    rename_table :media_sets_meta_contexts, :media_sets_contexts
    rename_column :meta_key_definitions, :meta_context_name, :context_id
    rename_column :media_sets_contexts, :meta_context_name, :context_id

    rename_column :app_settings, :second_displayed_meta_context_name, :second_displayed_context_id
    rename_column :app_settings, :third_displayed_meta_context_name, :third_displayed_context_id
  end
end
