class FilterSet < ActiveRecord::Base

  include Concerns::Entrust
  include Concerns::Favoritable

  serialize :filter, JSON

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
end
