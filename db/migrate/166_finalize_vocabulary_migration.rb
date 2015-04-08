class FinalizeVocabularyMigration < ActiveRecord::Migration

  def change
    change_column :meta_keys, :vocabulary_id, :string, null: false

    execute %q< ALTER TABLE vocabularies ADD CONSTRAINT vocabulary_id_chars CHECK (id ~* '^[a-z0-9\-\_]+$'); >
    execute %q< ALTER TABLE meta_keys ADD CONSTRAINT meta_key_id_chars CHECK (id ~* '^[a-z0-9\-\_\:]+$'); >
    execute %q< ALTER TABLE meta_keys ADD CONSTRAINT start_id_like_vocabulary_id CHECK (id like vocabulary_id || ':%' ); >

    remove_column :app_settings, :third_displayed_context_id
    remove_column :app_settings, :second_displayed_context_id

    drop_table :media_sets_contexts
    drop_table :meta_key_definitions
    drop_table :contexts
    drop_table :context_groups

  end

end
