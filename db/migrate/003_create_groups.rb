# -*- encoding : utf-8 -*-
class CreateGroups < ActiveRecord::Migration

  def up

    create_table  :groups do |t|

      t.string :name
      t.string :ldap_id
      t.string :ldap_name
      t.string :type, default: 'Group', null: false

    end

    add_index :groups, :type 
    add_index :groups, :ldap_id
    add_index :groups, :ldap_name

  end


  def down
    drop_table :groups
  end

end
