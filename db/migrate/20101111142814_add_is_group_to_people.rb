class AddIsGroupToPeople < ActiveRecord::Migration
  def self.up
    change_table  :people do |t|
      t.boolean    :is_group, :default => false
      t.index      :is_group
    end
  end

  def self.down
    change_table  :people do |t|
      t.remove_index  :is_group
      t.remove    :is_group
    end
  end
end
