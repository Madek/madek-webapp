class MediaEntry < ActiveRecord::Base

  include Concerns::Favoritable

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs
  has_many :collections, through: :collection_media_entry_arcs

  has_many :keywords

  belongs_to :responsible_user, class: User

  default_scope { reorder(:created_at,:id) }

  has_and_belongs_to_many :users_who_favored, join_table: "favorite_media_entries", class_name: "User"

end
