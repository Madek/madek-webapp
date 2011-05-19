# -*- encoding : utf-8 -*-
class UploadSession < ActiveRecord::Base
  
  belongs_to :user
  has_many :media_entries, :dependent => :destroy

  validates_presence_of :user

  default_scope order("created_at DESC")

  def to_s
    # TODO cached count column for media_entries
    "#{created_at.to_formatted_s(:date_time)} (#{media_entries.count})"
  end
  

end
