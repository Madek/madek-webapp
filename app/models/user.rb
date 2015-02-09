# -*- encoding : utf-8 -*-
# user is the system oriented representation of a User

class User < ActiveRecord::Base

  # include UserModules::Dropbox
  # include UserModules::TextSearch
  # include UserModules::AutoCompletion
  include Concerns::Users::Filters

  has_secure_password validations: false

  attr_accessor 'act_as_uberadmin'

  default_scope { reorder(:login) }

  belongs_to :person
  accepts_nested_attributes_for :person

  has_many :media_resources

  has_many :collections, foreign_key: :responsible_user_id
  has_many :media_entries, foreign_key: :responsible_user_id
  has_many :filter_sets, foreign_key: :responsible_user_id

  has_many :incomplete_media_entries,
           -> { where(type: 'MediaEntryIncomplete') },
           foreign_key: :creator_id,
           class_name: 'MediaEntry',
           dependent: :destroy

  has_many :created_media_entries,
           class_name: 'MediaEntry',
           foreign_key: :creator_id

  #############################################################

  has_many :keywords

  has_and_belongs_to_many :meta_data

  has_many :created_custom_urls, class_name: 'CustomUrl', foreign_key: :creator_id
  has_many :updated_custom_urls, class_name: 'CustomUrl', foreign_key: :updator_id

  has_and_belongs_to_many :favorite_media_entries,
                          join_table: 'favorite_media_entries',
                          class_name: 'MediaEntry'
  has_and_belongs_to_many :favorite_collections,
                          join_table: 'favorite_collections',
                          class_name: 'Collection'
  has_and_belongs_to_many :favorite_filter_sets,
                          join_table: 'favorite_filter_sets',
                          class_name: 'FilterSet'

  has_and_belongs_to_many :groups
  has_one :admin, dependent: :destroy

  #############################################################

  validates_format_of :email, with: /@/, message: "Email must contain a '@' sign."

  #############################################################

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  #############################################################

  def admin?
    !admin.nil?
  end

  #############################################################

  def reset_usage_terms
    update!(usage_terms_accepted_at: nil)
  end

  #############################################################

  def entrusted_media_entry_to_groups?(media_entry)
    media_entries
      .joins(:group_permissions)
      .where(media_entry_group_permissions:
        { media_entry_id: media_entry.id,
          get_metadata_and_previews: true })
      .exists?
  end

  def entrusted_media_entry_to_users?(media_entry)
    media_entries
      .joins(:user_permissions)
      .where(media_entry_user_permissions:
        { media_entry_id: media_entry.id,
          get_metadata_and_previews: true })
      .exists?
  end

  def entrusted_collection_to_groups?(collection)
    collections
      .joins(:group_permissions)
      .where(collection_group_permissions:
        { collection_id: collection.id,
          get_metadata_and_previews: true })
      .exists?
  end

  def entrusted_collection_to_users?(collection)
    collections
      .joins(:user_permissions)
      .where(collection_user_permissions:
        { collection_id: collection.id,
          get_metadata_and_previews: true })
      .exists?
  end

  def entrusted_filter_set_to_groups?(filter_set)
    filter_sets
      .joins(:group_permissions)
      .where(filter_set_group_permissions:
        { filter_set_id: filter_set.id,
          get_metadata_and_previews: true })
      .exists?
  end

  def entrusted_filter_set_to_users?(filter_set)
    filter_sets
      .joins(:user_permissions)
      .where(filter_set_user_permissions:
        { filter_set_id: filter_set.id,
          get_metadata_and_previews: true })
      .exists?
  end
end
