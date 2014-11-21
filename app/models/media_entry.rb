class MediaEntry < ActiveRecord::Base
  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs
  has_many :collections, through: :collection_media_entry_arcs

  belongs_to :responsible_user, class: User

  default_scope { reorder(:created_at,:id) }
end
