class DropLoggedInUsersPermission < ActiveRecord::Migration
  def self.up
    group = Group.create(:name => "ZHdK (Zürcher Hochschule der Künste)")

    permissions = Permission.where("actions_object LIKE '%:logged_in_users%'")
    permissions.each do |p|
      q = group.permissions.build(:resource => p.resource)
      actions = p.actions.select {|k,v| v == :logged_in_users}.map(&:first)
      
      h = {}
      actions.each {|a| h[a] = true}
      q.set_actions(h)
      
      h = {}
      actions.each {|a| h[a] = false}
      p.set_actions(h)
    end
    
  end

  def self.down
  end
end
