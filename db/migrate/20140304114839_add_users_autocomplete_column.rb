class AddUsersAutocompleteColumn < ActiveRecord::Migration
  def up
    add_column :users, :autocomplete, :string, null: false, default: ""
    User.all.each do |u|
      u.update_autocomplete
    end
    add_index :users, :autocomplete
  end

  def down
    remove_column :users, :autocomplete
  end
end
