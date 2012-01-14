class Userpermission < ActiveRecord::Base 
  belongs_to :media_resource, polymorphic: true
  belongs_to :permissionset
  belongs_to :user 

  after_destroy {|r| r.permissionset.destroy if r.permissionset}

end
