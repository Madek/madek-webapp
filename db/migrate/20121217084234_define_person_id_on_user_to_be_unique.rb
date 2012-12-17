class DefinePersonIdOnUserToBeUnique < ActiveRecord::Migration
  def up
    remove_index :users, :person_id
    add_index :users, :person_id, unique: true
  end

  def down
    remove_index :users, :person_id
    add_index :users, :person_id
  end
end
