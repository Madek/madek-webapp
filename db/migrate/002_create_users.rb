# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration

  def up

    create_table    :users do |t|

      t.integer     :person_id, null: false
      t.integer     :zhdkid
      t.string      :email, limit: 100
      t.string      :login, limit: 40
      t.string      :password
      t.text        :notes
      t.timestamp   :usage_terms_accepted_at

      t.timestamps
    end

    add_index :users, :login, unique: true
    add_index :users, :person_id
    add_index :users, :zhdkid, unique: true

    add_foreign_key :users, :people

  end


  def down
    drop_table :users
  end

end
