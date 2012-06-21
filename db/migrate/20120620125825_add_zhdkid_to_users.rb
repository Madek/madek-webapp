class AddZhdkidToUsers < ActiveRecord::Migration


  def up
    add_column :users, :zhdkid, :integer

    User.update_all("zhdkid = id", {password: nil})

  end

  def down
    remove_column :users, :zhdkid
  end

end
