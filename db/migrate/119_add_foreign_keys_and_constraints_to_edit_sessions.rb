class AddForeignKeysAndConstraintsToEditSessions < ActiveRecord::Migration

  def change

    add_foreign_key :edit_sessions, :media_entries, dependent: :destroy
    add_foreign_key :edit_sessions, :collections, dependent: :destroy
    add_foreign_key :edit_sessions, :filter_sets, dependent: :destroy

    reversible do |dir|
      dir.up do

        execute %{ ALTER TABLE edit_sessions ADD CONSTRAINT edit_sessions_is_related CHECK
                   (   (media_entry_id IS     NULL AND collection_id IS     NULL AND filter_set_id IS NOT NULL)
                    OR (media_entry_id IS     NULL AND collection_id IS NOT NULL AND filter_set_id IS     NULL)
                    OR (media_entry_id IS NOT NULL AND collection_id IS     NULL AND filter_set_id IS     NULL))
        };

      end
    end

  end
end
