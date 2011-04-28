# -*- encoding : utf-8 -*-
# user is the system oriented representation of a User

require 'digest/sha1'

class User < ActiveRecord::Base

  include Subject

  belongs_to :person
  delegate :name, :to => :person
  delegate :fullname, :to => :person

  has_many :upload_sessions do
    def latest
      first
    end
    def most_recents(limit = 3)
      all(:limit => limit)
    end
  end
  has_many :media_entries, :through => :upload_sessions
# TODO ??  has_many :media_files, :through => :media_entries
  has_many :media_sets, :class_name => "Media::Set"
  has_and_belongs_to_many :favorites, :class_name => "MediaEntry", :join_table => "favorites" do
    def toggle(media_entry_or_id)
      media_entry_id = media_entry_or_id.is_a?(MediaEntry) ? media_entry_or_id.id : media_entry_or_id.to_i
      if include?(media_entry_id)
        media_entry = where(:id => media_entry_id).first
        self.delete(media_entry)
      else
        new_favorite = MediaEntry.find(media_entry_id)
        self << new_favorite
      end
    end
    
    def include?(media_entry_id)
      exists? :id => media_entry_id
    end  
  end
    
  
  has_and_belongs_to_many :groups do
    def is_member?(group)
      # OPTIMIZE
      group = Group.find_or_create_by_name(group) if group.is_a? String
      include?(group)
    end
  end
  
#############################################################

  #0704#
#  def accessible_resources #(resource_type = nil, action = nil)
#    editable_ids = Permission.accessible_by_user("MediaEntry", current_user, :edit)
#    managable_ids = Permission.accessible_by_user("MediaEntry", current_user, :manage)
#  end

  # OPTIMIZE
  # return own and somebody else's sets, on which current_user has edit permission
  def editable_sets
    #old# Media::Set.select {|s| Permission.authorized?(self, :edit, s) }
    ids = Permission.accessible_by_user("Media::Set", self, :edit)
    Media::Set.where(:id => ids)
  end

#############################################################

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => /\A\w[\w\.\-_@]+\z/, :message => "use only letters, numbers, and .-_@ please."

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i, :message => "should look like an email address."

  validates_presence_of     :person_id

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
#temp#  attr_accessible :login, :email, :person_id

#############################################################

  def to_s
    name
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

#############################################################

  # TODO check against usage_terms version ??
  def usage_terms_accepted?
    usage_terms_accepted_at.to_i >= UsageTerm.current.updated_at.to_i
  end
  
  def usage_terms_accepted!
    update_attributes(:usage_terms_accepted_at => Time.now)
  end

end
