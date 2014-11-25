class Collection < ActiveRecord::Base 
  has_many :collection_media_entry_arcs

  has_many :media_entries, through: :collection_media_entry_arcs

  has_many :keywords

  default_scope { reorder(:created_at,:id) }
end
