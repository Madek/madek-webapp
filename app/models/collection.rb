class Collection < ActiveRecord::Base

  include Concerns::Favoritable

  belongs_to :responsible_user, class_name: 'User'
  belongs_to :creator, class_name: 'User'

  has_many :collection_media_entry_arcs

  has_many :media_entries, through: :collection_media_entry_arcs

  has_many :keywords

  default_scope { reorder(:created_at, :id) }

  has_and_belongs_to_many :users_who_favored,
                          join_table: 'favorite_collections',
                          class_name: 'User'

  has_many :edit_sessions, dependent: :destroy
  has_many :editors, through: :edit_sessions, source: :user

  #############################################################################

  has_many :user_permissions, class_name: 'Permissions::CollectionUserPermission'
  has_many :group_permissions, class_name: 'Permissions::CollectionGroupPermission'

  #############################################################################

  scope :entrusted_to_user_directly, lambda { |user|
    joins(:user_permissions)
      .where(collection_user_permissions: { user_id: user.id,
                                            get_metadata_and_previews: true })
  }

  scope :entrusted_to_user_through_groups, lambda { |user|
    joins(:group_permissions)
      .where(collection_group_permissions: { group_id: user.groups.map(&:id),
                                             get_metadata_and_previews: true })
  }

  def self.entrusted_to_user(user)
    scope1 = entrusted_to_user_directly(user)
    scope2 = entrusted_to_user_through_groups(user)
    sql = "((#{scope1.to_sql}) UNION (#{scope2.to_sql})) AS collections"
    from(sql)
  end
end
