class MediaEntry < ActiveRecord::Base
  include Concerns::MediaResourceAspect

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs

  has_many :collections, through: :collection_media_entry_arcs
  #has_and_belongs_to_many :collections, join_table: :collection_media_entry_arcs

  default_scope { reorder(:created_at,:id) }
end
