class Userpermission < ActiveRecord::Base 
  belongs_to :user

  belongs_to :media_resource, :polymorphic => true

  delegate :name, to: :user
#
#  has_one :media_sets_userpermissions_join
#  has_one :media_set, through: :media_sets_userpermissions_join
#

end
