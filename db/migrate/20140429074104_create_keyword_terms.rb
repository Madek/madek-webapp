class CreateKeywordTerms < ActiveRecord::Migration

  class Keyword < ActiveRecord::Base
    belongs_to :meta_term
    belongs_to :keyword_term
  end


  def change

    create_table :keyword_terms, id: false  do |t|
      t.uuid :id, null: false, default: 'uuid_generate_v4()'
      t.string :term, default: "", null: false
      t.timestamps
    end

    add_index :keyword_terms, :term, unique: true

    add_column :keywords, :keyword_term_id, :uuid, index: true
    add_index :keywords, :keyword_term_id


    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE keyword_terms ADD PRIMARY KEY (id)'

        Keyword.all.each do |keyword|
          keyword.update_attributes! keyword_term: KeywordTerm.find_or_create_by!(term:  keyword.meta_term[DEFAULT_LANGUAGE])
        end

        change_column :keywords, :keyword_term_id, :uuid, null: false
        add_foreign_key :keywords, :keyword_terms, column: :keyword_term_id

        remove_column :keywords, :meta_term_id
      end

      dir.down do
        raise "irreversible; disable for development (if you know what you are doing)"
      end
    end

  end
end
