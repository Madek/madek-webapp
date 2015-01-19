class Collection < ActiveRecord::Base

  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::Associations

  has_many :collection_media_entry_arcs

  has_many :media_entries, through: :collection_media_entry_arcs

  default_scope { reorder(:created_at, :id) }

  validates_presence_of :responsible_user, :creator
end
