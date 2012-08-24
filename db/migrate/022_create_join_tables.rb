class CreateJoinTables < ActiveRecord::Migration

  def up
    create_table :media_sets_meta_contexts, id: false do |t|
      t.integer :media_set_id, null: false
      t.integer :meta_context_id, null: false
    end
    add_index :media_sets_meta_contexts, [:media_set_id, :meta_context_id], name: :index_media_sets_meta_contexts,unique: true
    add_foreign_key :media_sets_meta_contexts, :media_resources, column: :media_set_id, dependent: :delete
    add_foreign_key :media_sets_meta_contexts, :meta_contexts, dependent: :delete

    create_table :meta_data_meta_departments, id: false do |t|
      t.integer :meta_datum_id, null: false
      t.integer :meta_department_id, null: false
    end
    add_index :meta_data_meta_departments, [:meta_datum_id,:meta_department_id], name: :index_meta_data_meta_departments, unique: true
    add_foreign_key :meta_data_meta_departments, :meta_data, dependent: :delete
    add_foreign_key :meta_data_meta_departments, :groups, column: :meta_department_id, dependent: :delete

    create_table :meta_data_meta_terms, id: false do |t|
      t.integer :meta_datum_id, null: false
      t.integer :meta_term_id, null: false
    end
    add_index :meta_data_meta_terms, [:meta_datum_id,:meta_term_id], unique: true
    add_foreign_key :meta_data_meta_terms, :meta_data, dependent: :delete
    add_foreign_key :meta_data_meta_terms, :meta_terms, dependent: :delete

    create_table :meta_data_people, id: false do |t|
      t.integer :meta_datum_id, null: false
      t.integer :person_id, null: false
    end
    add_index :meta_data_people, [:meta_datum_id,:person_id], unique: true
    add_foreign_key :meta_data_people, :meta_data, dependent: :delete
    add_foreign_key :meta_data_people, :people, dependent: :delete

    create_table :meta_data_users, id: false do |t|
      t.integer :meta_datum_id, null: false
      t.integer :user_id, null: false
    end
    add_index :meta_data_users, [:meta_datum_id,:user_id], unique: true
    add_foreign_key :meta_data_users, :meta_data, dependent: :delete
    add_foreign_key :meta_data_users, :users, dependent: :delete

  end

  def down
    drop_table :media_sets_meta_contexts
    drop_table :meta_data_meta_departments
    drop_table :meta_data_meta_terms
    drop_table :meta_data_people
    drop_table :meta_data_users
  end


end
