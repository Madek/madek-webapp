class Collection < ActiveRecord::Base 

  include Concerns::Favoritable

  belongs_to :responsible_user, class_name: "User"
  belongs_to :creator, class_name: "User"

  has_many :collection_media_entry_arcs

  has_many :media_entries, through: :collection_media_entry_arcs

  has_many :keywords

  default_scope { reorder(:created_at,:id) }

  has_and_belongs_to_many :users_who_favored, join_table: "favorite_collections", class_name: "User"

  has_many :edit_sessions, dependent: :destroy
  has_many :editors, through: :edit_sessions, source: :user

end
