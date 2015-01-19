class MediaEntry < ActiveRecord::Base

  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::Associations
  include Concerns::Scopes

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs
  has_many :collections, through: :collection_media_entry_arcs

  default_scope { reorder(:created_at, :id) }

  has_and_belongs_to_many :users_who_favored,
                          join_table: 'favorite_media_entries',
                          class_name: 'User'

  validates_presence_of :responsible_user, :creator
end
