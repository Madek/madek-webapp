class AddNotesAndZhdkidToUsers < ActiveRecord::Migration

  def up
    change_table :users do |t|
      t.text :notes
      t.integer :zhdkid
      t.index :zhdkid
    end

    User.update_all("zhdkid = id", {password: nil})
  end

  def down
    change_table :users do |t|
      t.remove :notes
      t.remove :zhdkid
    end
  end

end
