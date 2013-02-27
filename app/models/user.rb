# -*- encoding : utf-8 -*-
# user is the system oriented representation of a User

require 'digest/sha1'

class User < ActiveRecord::Base

  belongs_to :person
  delegate :name, :fullname, :shortname, :to => :person

  has_many :userpermissions

  has_many :media_resources
  has_many :media_sets
  has_many :media_entries
  has_many :incomplete_media_entries, :class_name => "MediaEntryIncomplete", :dependent => :destroy
  has_many :keywords 

  has_and_belongs_to_many :favorites, :class_name => "MediaResource", :join_table => "favorites" do
    def toggle(media_resource)
      if exists?(media_resource)
        self.delete(media_resource)
      else
        self << media_resource
      end
    end
    def favor(media_resource)
      self << media_resource
    end
    def disfavor(media_resource)
      self.delete(media_resource) if exists?(media_resource)
    end
  end
  


  has_and_belongs_to_many :groups do
    def is_member?(group)
      group = Group.find_by_name(group) if group.is_a? String
      group ? include?(group) : false
    end
  end

  def is_admin? 
    @is_admin ||= Group.where(name: 'Admin').joins(:users) \
      .where("groups_users.user_id = ?", self.id).count > 0
  end

  #############################################################

  def individual_contexts
    # NOTE media_sets scope includes the subclasses (FilterSet) 
    r = MediaSet.media_sets.accessible_by_user(self).select("media_resources.id")
    MetaContext.joins(:media_sets).uniq.where(:media_resources => {:id => r})
  end

#############################################################

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  # DANGER: This validation is broken! It allows only ASCII characters (\w only includes those), but our users have umlauts etc. in their logins!
  #  validates_format_of       :login,    :with => /\A\w[\w\.\-_@]+\z/, :message => "use only letters, numbers, and .-_@ please."


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

  before_create do
    self.password = Digest::SHA1.hexdigest(self.password) unless self.password.blank?
  end

#############################################################
  
  def self.find_by_login(login)
    where("login #{SQLHelper.ilike} ?",login).limit(1).first
  end

  def to_s
    name
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def dropbox_dir_name
    if persisted?
      sha = Digest::SHA1.hexdigest("#{id}#{created_at}")
      "#{id}_#{sha}"    
    else
      raise "The user record has to be persisted."
    end
  end

#############################################################

  def authorized?(action, resource_or_resources)
    Array(resource_or_resources).all? do |resource|
      if resource.user == self
        true
      elsif resource.send(action) == true
        true
      elsif resource.userpermissions.disallows(self, action)
        false
      elsif resource.userpermissions.allows(self, action)
        true
      elsif resource.grouppermissions.allows(self, action)
        true
      else
        false
      end
    end 
  end

#############################################################

  def is_guest?
    !persisted?
  end

#############################################################

  def dropbox_dir
    if AppSettings.dropbox_root_dir and 
    File.directory? AppSettings.dropbox_root_dir and
    File.directory? AppSettings.dropbox_root_dir and
    File.directory? File.join(AppSettings.dropbox_root_dir, dropbox_dir_name)
      File.join(AppSettings.dropbox_root_dir, dropbox_dir_name)
    end
  end

  def dropbox_files
    if dropbox_dir
      Dir.glob(File.join(dropbox_dir, '**', '*')).
                    select {|x| not File.directory?(x) }.
                    map {|f| {:dirname=> File.dirname(f).gsub(dropbox_dir, ''),
                              :filename=> File.basename(f),
                              :size => File.size(f) }}
    end
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
