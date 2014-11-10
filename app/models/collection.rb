class Collection < ActiveRecord::Base 
  include Concerns::MediaResourceAspect

  has_many :collection_media_entry_arcs

  has_many :media_entries, through: :collection_media_entry_arcs
  #has_and_belongs_to_many :media_entries, join_table: :collection_media_entry_arcs

  default_scope { reorder(:created_at,:id) }
end
