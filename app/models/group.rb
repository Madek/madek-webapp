class Group < ActiveRecord::Base

  has_many :grouppermissions
  has_and_belongs_to_many :users

end
