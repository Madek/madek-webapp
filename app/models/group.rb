# -*- encoding : utf-8 -*-
class Group < ActiveRecord::Base
  include Subject
  # FIXME breaking permissions # include Resource
  
  has_and_belongs_to_many :users

  validates_presence_of :name

  scope :departments, where(:type => "Meta::Department")

  def to_s
    name
  end

  def is_readonly?
    ["Admin", "Expert", "MIZ-Archiv"].include?(name)
  end

end
