class MediaEntry < ActiveRecord::Base

  include Concerns::Favoritable

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs
  has_many :collections, through: :collection_media_entry_arcs

  has_many :keywords

  belongs_to :responsible_user, class_name: 'User'
  belongs_to :creator, class_name: 'User'

  default_scope { reorder(:created_at, :id) }

  has_and_belongs_to_many :users_who_favored, join_table: 'favorite_media_entries', class_name: 'User'

  has_many :edit_sessions, dependent: :destroy
  has_many :editors, through: :edit_sessions, source: :user

  validates_presence_of :responsible_user

end
