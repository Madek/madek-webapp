# -*- encoding : utf-8 -*-
# user is the system oriented representation of a User

require 'digest/sha1'

class User < ActiveRecord::Base

  include Subject

  Constants::Actions.each do |action|
    {media_resource: MediaResource}.each do |singular,model|
      has_and_belongs_to_many "#{action}able_#{singular.to_s.pluralize}",  class_name: model.to_s, 
        join_table: "#{action}able_#{singular.to_s.pluralize}_users", foreign_key: :user_id, association_foreign_key: "#{singular.to_s}_id"
    end
  end

  def destroy 
    # TODO, for now since the above is not compatible with destroy, seems to be a rails problem
    warn "destroy will is overwitten to use delete in the background"
    delete
  end

  belongs_to :person
  delegate :name, :to => :person
  delegate :fullname, :to => :person

  has_many :userpermissions

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
  has_many :media_sets
  has_and_belongs_to_many :favorites, :class_name => "MediaResource", :join_table => "favorites" do
    def toggle(media_resource)
      if exists?(media_resource)
        self.delete(media_resource)
      else
        self << media_resource
      end
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

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => /\A\w[\w\.\-_@]+\z/, :message => "use only letters, numbers, and .-_@ please."

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i, :message => "should look like an email address."

  validates_presence_of     :person

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
