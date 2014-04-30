class MoveMetaTermLabelsToTheirParentModels < ActiveRecord::Migration
  def change
    add_column :meta_contexts, :label, :string, default: "", null: false
    add_column :meta_contexts, :description, :string, default: "", null: false

    add_column :meta_key_definitions, :label, :string, default: "", null: false
    add_column :meta_key_definitions, :hint, :string, default: "", null: false
    add_column :meta_key_definitions, :description, :string, default: "", null: false

    reversible do |dir|
      dir.up do

        execute %Q[ UPDATE meta_contexts
                    SET label= meta_terms.de_ch
                    FROM meta_terms
                    WHERE meta_contexts.label_id = meta_terms.id ]

        execute %Q[ UPDATE meta_contexts
                    SET description = meta_terms.de_ch
                    FROM meta_terms
                    WHERE meta_contexts.description_id = meta_terms.id ]


        execute %Q[ UPDATE meta_key_definitions
                    SET label= meta_terms.de_ch
                    FROM meta_terms
                    WHERE meta_key_definitions.label_id = meta_terms.id ]

        execute %Q[ UPDATE meta_key_definitions
                    SET hint= meta_terms.de_ch
                    FROM meta_terms
                    WHERE meta_key_definitions.hint_id = meta_terms.id ]

        execute %Q[ UPDATE meta_key_definitions
                    SET description = meta_terms.de_ch
                    FROM meta_terms
                    WHERE meta_key_definitions.description_id = meta_terms.id ]

      end
    end

    remove_column :meta_contexts, :label_id
    remove_column :meta_contexts, :description_id

    remove_column :meta_key_definitions, :label_id
    remove_column :meta_key_definitions, :hint_id
    remove_column :meta_key_definitions, :description_id

  end

end
