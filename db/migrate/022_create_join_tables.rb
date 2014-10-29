class CreateJoinTables < ActiveRecord::Migration

  def change
    create_table :media_sets_contexts, id: false do |t|
      t.uuid :media_set_id, null: false
      t.string :context_id, null: false
    end
    add_index :media_sets_contexts, [:media_set_id, :context_id], name: :index_media_sets_contexts,unique: true
    add_foreign_key :media_sets_contexts, :media_resources, column: :media_set_id, dependent: :delete
    add_foreign_key :media_sets_contexts, :contexts, dependent: :delete

    create_table :meta_data_institutional_groups, id: false do |t|
      t.uuid :meta_datum_id, null: false
      t.uuid :institutional_group_id, null: false
    end
    add_index :meta_data_institutional_groups, [:meta_datum_id,:institutional_group_id], name: :index_meta_data_institutional_groups, unique: true
    add_foreign_key :meta_data_institutional_groups, :meta_data, dependent: :delete
    add_foreign_key :meta_data_institutional_groups, :groups, column: :institutional_group_id, dependent: :delete

    create_table :meta_data_meta_terms, id: false do |t|
      t.uuid :meta_datum_id, null: false
      t.uuid :meta_term_id, null: false
    end
    add_index :meta_data_meta_terms, [:meta_datum_id,:meta_term_id], unique: true
    add_foreign_key :meta_data_meta_terms, :meta_data, dependent: :delete
    add_foreign_key :meta_data_meta_terms, :meta_terms, dependent: :delete

    create_table :meta_data_people, id: false do |t|
      t.uuid :meta_datum_id, null: false
      t.uuid :person_id, null: false
    end
    add_index :meta_data_people, [:meta_datum_id,:person_id], unique: true
    add_foreign_key :meta_data_people, :meta_data, dependent: :delete
    add_foreign_key :meta_data_people, :people

    create_table :meta_data_users, id: false do |t|
      t.uuid :meta_datum_id, null: false
      t.uuid :user_id, null: false
    end
    add_index :meta_data_users, [:meta_datum_id,:user_id], unique: true
    add_foreign_key :meta_data_users, :meta_data, dependent: :delete
    add_foreign_key :meta_data_users, :users, dependent: :delete

  end

end
