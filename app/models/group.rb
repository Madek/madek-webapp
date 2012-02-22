# -*- encoding : utf-8 -*-
class Group < ActiveRecord::Base

  has_many :grouppermissions
  has_and_belongs_to_many :users


  validates_presence_of :name

  scope :departments, where(:type => "MetaDepartment")

  def to_s
    name
  end

  def is_readonly?
    ["Admin", "Expert", "MIZ-Archiv", "ZHdK (Zürcher Hochschule der Künste)"].include?(name)
  end
  
end
