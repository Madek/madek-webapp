# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :users, id: :uuid do |t|

      t.integer :previous_id

      t.string :email

      t.text :login
      t.index :login

      t.text :notes

      t.timestamps null: false

      t.string :password_digest

      t.uuid :person_id, null: false
      t.index :person_id, unique: true

      t.integer :zhdkid
      t.index :zhdkid, unique: true

      t.timestamp :usage_terms_accepted_at

      t.text :searchable, default: '', null: false
      t.text :trgm_searchable, default: '', null: false

      t.text :autocomplete, null: false, default: ''
      t.index :autocomplete

      t.boolean :contrast_mode, null: false, default: false

    end

    reversible do |dir|
      dir.up do
        execute %q< ALTER TABLE users ADD CONSTRAINT users_login_simple CHECK (login ~* '^[a-z0-9\.\-\_]+$'); >
        set_timestamps_defaults :users
        create_trgm_index :users, :trgm_searchable
        create_text_index :users, :searchable
      end
    end

    add_foreign_key :users, :people
  end

end
