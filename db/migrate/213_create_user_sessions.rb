class CreateUserSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_sessions, id: :uuid do |t|
      t.text :token_hash, null: false
      t.uuid :user_id, index: true
      t.uuid :delegation_id
      t.column :created_at, 'timestamp with time zone', default: 'now()'
    end

    add_index :user_sessions, :token_hash, unique: true

    add_column :settings, :sessions_max_lifetime_secs, :integer, default: 5 * 24 * 60 * 60 # 5 Days
    add_column :settings, :sessions_force_uniqueness, :boolean, default: true, null: false
    add_column :settings, :sessions_force_secure, :boolean, default: false, null: false

    add_foreign_key :user_sessions, :users, on_delete: :cascade
    add_foreign_key :user_sessions, :users, column: :delegation_id, on_delete: :nullify

    reversible do |dir|
      dir.up do
        execute "ALTER TABLE user_sessions ALTER COLUMN created_at SET DEFAULT now()"
      end
    end

  end


end

