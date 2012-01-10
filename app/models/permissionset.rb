class Permissionset < ActiveRecord::Base
  has_one Userpermission.name.downcase
  has_one Grouppermission.name.downcase
  has_one MediaResource.name.downcase
end
