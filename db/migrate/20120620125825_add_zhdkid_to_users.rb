class AddZhdkidToUsers < ActiveRecord::Migration


  def up
    add_column :users, :zhdkid, :integer

    user_klass = Class.new(ActiveRecord::Base) do
      self.table_name = "users"
    end

    user_klass.all.each do |user|
      user.update_attributes({zhdkid: user.id}) unless user.password
    end

  end

  def down
    remove_column :users, :zhdkid
  end

end
