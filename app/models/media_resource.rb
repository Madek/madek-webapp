class MediaResource < ActiveRecord::Base

  has_many :userpermissions
  has_many :grouppermissions
  belongs_to :owner, :class_name => User.name

  has_one :media_entry
  has_one :media_set
  
end
