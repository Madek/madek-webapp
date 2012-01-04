class Grouppermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :media_resource, :polymorphic => true

#  has_one :media_sets_userpermissions_join
#  has_one :media_set, through: :media_sets_userpermissions_join
#

end
