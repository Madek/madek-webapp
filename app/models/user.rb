# -*- encoding : utf-8 -*-
# user is the system oriented representation of a User

class User < ActiveRecord::Base
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

  belongs_to :person
  delegate :name, :fullname, :shortname, :to => :person

  has_many :userpermissions

  has_many :media_resources
  has_many :media_sets
  has_many :media_entries
  has_many :incomplete_media_entries, :class_name => "MediaEntryIncomplete", :dependent => :destroy
  has_many :keywords 
  has_and_belongs_to_many :meta_data

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
    r = MediaSet.media_sets.accessible_by_user(self,:view).select("media_resources.id")
    MetaContext.joins(:media_sets).uniq.where(:media_resources => {:id => r})
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
      case action.to_sym
      when :delete
        resource.user == self
      else
        MediaResource.where(id: resource).
          accessible_by_user(self,action).count > 0
      end
    end
  end

#############################################################

  def is_guest?
    !persisted?
  end

#############################################################

  # returns the path as string or false if it doesn't exist
  def dropbox_dir app_settings
    _dropbox_dir = dropbox_dir_path(app_settings)
    File.directory?(_dropbox_dir) and _dropbox_dir
  end

  # returns the path as string, even if it doesn't exist
  def dropbox_dir_path app_settings
    File.join(app_settings.dropbox_root_dir.to_s, dropbox_dir_name)
  end

  def dropbox_files app_settings
    if dd = dropbox_dir(app_settings)
      Dir.glob(File.join(dd, '**', '*')).
                    select {|x| not File.directory?(x) }.
                    map {|f| {:dirname=> File.dirname(f).gsub(dd, ''),
                              :filename=> File.basename(f),
                              :size => File.size(f) }}
    end
  end

  def dropbox_dir_name
    if persisted?
      sha = Digest::SHA1.hexdigest("#{id}#{created_at}")
      "#{id}_#{sha}"    
    else
      raise "The user record has to be persisted."
    end
  end



  def usage_terms_accepted?
    usage_terms_accepted_at.to_i >= UsageTerm.current.updated_at.to_i
  end
  
  def usage_terms_accepted!
    update_attributes(:usage_terms_accepted_at => Time.now)
  end


  ### text search ######################################## 
  # postgres' text doesn't split up email addresses; let's do it manually in a searchable field;
  # since we have searchable field, let's put all strings in there; searching is simpler and we need only one index 
  
  def convert_to_searchable str
    [str,str.gsub(/[^\w]/,' ').split(/\s+/)].flatten.sort.join(' ')
  end

  def update_searchable
    update_columns searchable: [convert_to_searchable(login),convert_to_searchable(email),
                                person.last_name,person.first_name,person.pseudonym] \
                                .flatten.compact.sort.uniq.join(" ")
  end

  def update_trgm_searchable
    update_columns trgm_searchable: [login,email,person.last_name,
                                     person.first_name,person.pseudonym] \
                                     .flatten.compact.sort.uniq.join(" ")
  end

  scope :text_search, lambda{|search_term| basic_search({searchable: search_term},true)}

  scope :text_rank_search, lambda{|search_term| 
    rank= text_search_rank :searchable, search_term
    select("#{'users.*,' if select_values.empty?}  #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }

  scope :trgm_rank_search, lambda{|search_term| 
    rank= trgm_search_rank :trgm_searchable, search_term
    select("#{'users.*,' if select_values.empty?} #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }

end
