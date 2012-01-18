class Userpermission < ActiveRecord::Base 
  belongs_to :media_resource, polymorphic: true
  belongs_to :user 

end
