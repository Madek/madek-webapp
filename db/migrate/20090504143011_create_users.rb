# -*- encoding : utf-8 -*-

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.belongs_to :person, :null => false
      t.column :login,                     :string, :limit => 40
      t.column :email,                     :string, :limit => 100
#old#
#      t.column :name,                      :string, :limit => 100, :default => '', :null => true
#      t.column :crypted_password,          :string, :limit => 40
#      t.column :salt,                      :string, :limit => 40
#      t.column :remember_token,            :string, :limit => 40
#      t.column :remember_token_expires_at, :datetime
      
      t.timestamps
    end

    change_table :users do |t|
      t.index :person_id
      t.index :login, :unique => true
    end



  end

  def self.down
    drop_table :users
  end
end
