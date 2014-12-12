class FilterSet < ActiveRecord::Base

  include Concerns::Favoritable

  belongs_to :responsible_user, class_name: 'User'
  belongs_to :creator, class_name: 'User'

  has_many :keywords

  has_many :edit_sessions, dependent: :destroy
  has_many :editors, through: :edit_sessions, source: :user

  has_and_belongs_to_many :users_who_favored, join_table: 'favorite_filter_sets', class_name: 'User'

end
