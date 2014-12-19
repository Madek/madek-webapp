class MediaEntry < ActiveRecord::Base

  include Concerns::Favoritable

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs
  has_many :collections, through: :collection_media_entry_arcs

  has_many :keywords

  belongs_to :responsible_user, class_name: 'User'
  belongs_to :creator, class_name: 'User'

  default_scope { reorder(:created_at, :id) }

  has_and_belongs_to_many :users_who_favored,
                          join_table: 'favorite_media_entries',
                          class_name: 'User'

  has_many :edit_sessions, dependent: :destroy
  has_many :editors, through: :edit_sessions, source: :user

  validates_presence_of :responsible_user, :creator

  #############################################################################

  has_many :user_permissions, class_name: 'Permissions::MediaEntryUserPermission'
  has_many :group_permissions, class_name: 'Permissions::MediaEntryGroupPermission'

  #############################################################################

  scope :entrusted_to_user_directly, lambda { |user|
    joins(:user_permissions)
      .where(media_entry_user_permissions: { user_id: user.id,
                                             get_metadata_and_previews: true })
  }

  scope :entrusted_to_user_through_groups, lambda { |user|
    joins(:group_permissions)
      .where(media_entry_group_permissions: { group_id: user.groups.map(&:id),
                                              get_metadata_and_previews: true })
  }

  def self.entrusted_to_user(user)
    scope1 = entrusted_to_user_directly(user)
    scope2 = entrusted_to_user_through_groups(user)
    sql = "((#{scope1.to_sql}) UNION (#{scope2.to_sql})) AS media_entries"
    from(sql)
  end
end
