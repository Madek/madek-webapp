# -*- encoding : utf-8 -*-
class EditSession < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  validates_presence_of :user

  default_scope order("created_at DESC")

end
