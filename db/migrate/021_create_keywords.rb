class CreateKeywords < ActiveRecord::Migration
  include MigrationHelper


  def change

    create_table :keyword_terms, id: :uuid do |t|
      t.string :term, default: "", null: false
      t.timestamps null: false
      t.uuid :creator_id
    end

    reversible do |dir|
      dir.up do 
        set_timestamps_defaults :keyword_terms
        create_trgm_index :keyword_terms, :term
        create_text_index :keyword_terms, :term
      end
    end


    create_table :keywords, id: :uuid do |t|
      t.uuid :user_id
      t.index :user_id

      t.uuid :meta_datum_id
      t.index :meta_datum_id

      t.uuid :keyword_term_id
      t.index :keyword_term_id

      t.timestamps null: false
      t.index :created_at
    end

    reversible do |dir|
      dir.up do 
        set_timestamps_defaults :keywords
      end
    end

    add_foreign_key :keywords, :keyword_terms
    add_foreign_key :keywords, :users
    add_foreign_key :keywords, :meta_data, dependent: :delete

  end

end
