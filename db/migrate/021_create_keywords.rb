class CreateKeywords < ActiveRecord::Migration
  def up

    create_table :keywords do |t|
      t.integer  :meta_term_id, null: false
      t.integer  :user_id
      t.integer  :meta_datum_id, null: false      

      t.timestamp :created_at
    end

    add_index :keywords, :created_at
    add_index :keywords, :meta_datum_id
    add_index :keywords, :user_id
    add_index :keywords, [:meta_term_id,:user_id]

    add_foreign_key :keywords, :users
    add_foreign_key :keywords, :meta_terms
    add_foreign_key :keywords, :meta_data, dependent: :delete

  end

  def down
    drop_table :keywords
  end
end
