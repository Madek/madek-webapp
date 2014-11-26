# -*- encoding : utf-8 -*-
# user is the system oriented representation of a User

class User < ActiveRecord::Base

  include UserModules::Dropbox
  include UserModules::TextSearch
  include UserModules::AutoCompletion


  has_secure_password  validations: false 

  attr_accessor 'act_as_uberadmin'

  default_scope { reorder(:login) }

  after_save :update_searchable
  after_save :update_trgm_searchable

  # using a view here saves us from having a GROUP BY in the scope, which gives all sorts
  # of problems when we try to chain further
  scope :with_resources_amount, ->{
    select("users.*, COALESCE(user_resources_counts.resouces_count,0) as resources_amount").
    joins("LEFT OUTER JOIN user_resources_counts ON user_resources_counts.user_id = users.id") }

  scope :sort_by_resouces_amount, ->{ reorder("resources_amount desc")}

  scope :order_by_last_name_first_name, ->{
    joins(:person).reorder("people.last_name, people.first_name, people.pseudonym") }

  scope :admin_users, ->{
    joins(:admin_user)
  }

  belongs_to :person
  delegate :name, :fullname, :shortname, :to => :person

  has_one :admin_user, dependent: :destroy

  has_many :userpermissions

  has_many :media_resources
  has_many :media_sets
  has_many :media_entries
  has_many :incomplete_media_entries, :class_name => "MediaEntryIncomplete", :dependent => :destroy
  has_many :keywords 
  has_and_belongs_to_many :meta_data

  has_many :created_custom_urls, class_name: 'CustomUrl', foreign_key: :creator_id
  has_many :updated_custom_urls, class_name: 'CustomUrl', foreign_key: :updator_id

  has_and_belongs_to_many :favorite_media_entries, join_table: "favorite_media_entries", class_name: "MediaEntry"
  has_and_belongs_to_many :favorite_collections, join_table: "favorite_collections", class_name: "Collection"

  has_and_belongs_to_many :groups,
                          after_add: :increment_user_counter, 
                          after_remove: :decrement_user_counter do
    def is_member?(group)
      group = Group.find_by_name(group) if group.is_a? String
      group ? include?(group) : false
    end
  end

  def is_admin? 
    !! admin_user
  end

### counters ###################################################
  def increment_user_counter(group)
    group.increment!(:users_count)
  end

  def decrement_user_counter(group)
    group.decrement!(:users_count)
  end

  #############################################################

  def individual_contexts
    # NOTE media_sets scope includes the subclasses (FilterSet) 
    r = MediaSet.media_sets.accessible_by_user(self,:view).select("media_resources.id")
    Context.joins(:media_sets).uniq.where(:media_resources => {:id => r})
  end

#############################################################
  

  # NOTE login constraints are enforced on the db layer now 
  # NOTE contrary to what was noted previously here: ZHDK logins do only use ascii lowercase without
  #   umlauts etc, and sometimes numbers; nothing else! This information was given to me in Feb 2014.

  # NOTE removed the old email validation; it was WAY to restrictive
  #  http://davidcel.is/blog/2012/09/06/stop-validating-email-addresses-with-regex/
  validates_format_of  :email,  :with => /@/, :message => "Email must contain a '@' sign."


#############################################################
  
  def self.find_by_login(login)
    where("login ilike ?",login).limit(1).first
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

#############################################################

  def authorized?(action, resource_or_resources)
    Array(resource_or_resources).all? do |resource|
      MediaResource.where(id: resource).
        accessible_by_user(self,action).count > 0
    end
  end

#############################################################

  def is_guest?
    !persisted?
  end

#############################################################


  def usage_terms_accepted?
    usage_terms_accepted_at.to_i >= UsageTerm.current.updated_at.to_i
  end
  
  def usage_terms_accepted!
    update_attributes(:usage_terms_accepted_at => Time.now)
  end

  def reset_usage_terms
    update_attributes(usage_terms_accepted_at: nil)
  end



end
