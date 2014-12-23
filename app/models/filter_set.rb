class FilterSet < ActiveRecord::Base

  include Concerns::Favoritable

  belongs_to :responsible_user, class_name: 'User'
  belongs_to :creator, class_name: 'User'

  has_many :keywords

  has_many :edit_sessions, dependent: :destroy
  has_many :editors, through: :edit_sessions, source: :user

  has_and_belongs_to_many :users_who_favored,
                          join_table: 'favorite_filter_sets',
                          class_name: 'User'

  validates_presence_of :responsible_user, :creator

  #############################################################################

  has_many :user_permissions, class_name: 'Permissions::FilterSetUserPermission'
  has_many :group_permissions, class_name: 'Permissions::FilterSetGroupPermission'

  #############################################################################

  scope :entrusted_to_user_directly, lambda { |user|
    joins(:user_permissions)
      .where(filter_set_user_permissions: { user_id: user.id,
                                            get_metadata_and_previews: true })
  }

  scope :entrusted_to_user_through_groups, lambda { |user|
    joins(:group_permissions)
      .where(filter_set_group_permissions: { group_id: user.groups.map(&:id),
                                             get_metadata_and_previews: true })
  }

  def self.entrusted_to_user(user)
    scope1 = entrusted_to_user_directly(user)
    scope2 = entrusted_to_user_through_groups(user)
    sql = "((#{scope1.to_sql}) UNION ALL (#{scope2.to_sql})) AS filter_sets"

    # NOTE: DISTINCT ON in conjunction with UNION ALL
    # due to missing json equality operator in PG 9.3
    #
    # ON (filter_sets.id, filter_sets.created_at)
    # due to 'SELECT DISTINCT ON expressions must match
    # initial ORDER BY expressions'
    #
    # take care!! ActiveRecord.count does not work with sub_queries
    # see bug https://github.com/rails/rails/issues/11824
    select('DISTINCT ON (filter_sets.id, filter_sets.created_at) filter_sets.*')
      .from(sql)
  end
end
