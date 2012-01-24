# -*- encoding : utf-8 -*-
class UploadSession < ActiveRecord::Base
  
  belongs_to :user
  has_many :incomplete_media_entries, :class_name => "MediaEntryIncomplete", :dependent => :destroy # OPTIMIZE allow remove only incomplete upload_sessions
  has_many :media_entries

  validates_presence_of :user

  default_scope order("created_at DESC")

  def to_s
    # TODO cached count column for media_entries
    "#{created_at.to_formatted_s(:date_time)} (#{media_entries.count})"
  end
  
  def set_as_complete
    transaction do
      incomplete_media_entries.each do |me|
        me = me.becomes MediaEntry
        me.save
      end
      update_attributes(:is_complete => true)
    end
  end

end
