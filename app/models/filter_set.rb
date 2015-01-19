class FilterSet < ActiveRecord::Base

  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::Associations

  serialize :filter, JSON

  has_and_belongs_to_many :users_who_favored,
                          join_table: 'favorite_filter_sets',
                          class_name: 'User'

  validates_presence_of :responsible_user, :creator
end
