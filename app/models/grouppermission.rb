class Grouppermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :media_resource
  belongs_to :permissionset

  delegate :name, to: :group

#  has_one :media_sets_userpermissions_join
#  has_one :media_set, through: :media_sets_userpermissions_join
#

end
