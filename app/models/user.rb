# -*- encoding : utf-8 -*-
# user is the system oriented representation of a User

class User < ActiveRecord::Base

  # include UserModules::Dropbox
  # include UserModules::TextSearch
  # include UserModules::AutoCompletion


  has_secure_password  validations: false 

  attr_accessor 'act_as_uberadmin'

  default_scope { reorder(:login) }

  belongs_to :person


  has_many :media_resources
  has_many :media_sets
  has_many :media_entries, foreign_key: :responsible_user_id
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



#############################################################

  validates_format_of  :email,  :with => /@/, :message => "Email must contain a '@' sign."


#############################################################
  
  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

#############################################################


end
