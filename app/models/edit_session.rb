# -*- encoding : utf-8 -*-
class EditSession < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :media_resource

  validates_presence_of :user

  default_scope order("edit_sessions.created_at DESC")

end
