class Userpermission < ActiveRecord::Base 
  belongs_to :media_resource 
  belongs_to :permissionset
  belongs_to :user 
end
