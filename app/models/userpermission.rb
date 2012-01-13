class Userpermission < ActiveRecord::Base 
  belongs_to :media_resource, polymorphic: true
  belongs_to :permissionset
  belongs_to :user 

  Constants::Actions.each do |action|
    delegate action, :to => :permissionset
    delegate "#{action}=", :to => :permissionset
  end
end
