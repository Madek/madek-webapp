class RefactorMetaDepartments < ActiveRecord::Migration
  def self.up
    change_table :groups do |t|
      t.string :ldap_id
      t.string :ldap_name
      t.string :type, :null => false, :default => 'Group'   # STI (single table inheritance)

      t.index :ldap_id
      t.index :ldap_name
      t.index :type
    end
    
    drop_table :meta_departments
  end

  def self.down
  end
end
