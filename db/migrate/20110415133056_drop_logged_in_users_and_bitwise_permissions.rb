# coding: UTF-8

class DropLoggedInUsersAndBitwisePermissions < ActiveRecord::Migration
  def self.up
    change_table :permissions do |t|
      t.integer :action_bits, :null => false, :default => 0
      t.integer :action_mask, :null => false, :default => 0
      t.index [:action_bits, :action_mask]
    end
  
#    group = Group.find_or_create_by_name(:name => "ZHdK (Zürcher Hochschule der Künste)")    
    #    this group is created through the db:seed  task
#
#    Permission.where("actions_object LIKE '%:logged_in_users%'").each do |p|
#      q = group.permissions.build(:media_resource => p.media_resource)
#      h = YAML.load(p.actions_object).ivars["keys"]
#      actions = h.select {|k,v| v == :logged_in_users}.map(&:first)
#      h = {}
#      actions.each {|a| h[a] = true}
#      q.set_actions(h)
#      h = {}
#      actions.each {|a| h[a] = false}
#      p.set_actions(h)
#    end
#
#    Permission.where("actions_object IS NOT NULL").each do |permission|
#      h = YAML.load(permission.actions_object).ivars["keys"]
#      h[:hi_res] ||= h[:high_res] if h[:high_res]
#      permission.set_actions(h)
#    end

    change_table :permissions do |t|
      t.remove :actions_object
    end
  end

  def self.down
  end
end
