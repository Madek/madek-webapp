class MediaEntry < ActiveRecord::Base

  include Concerns::Collections::Siblings
  include Concerns::MediaEntries::Filters
  include Concerns::MediaResources

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs, class_name: Arcs::CollectionMediaEntryArc
  has_many :parent_collections,
           through: :collection_media_entry_arcs,
           source: :collection

  default_scope { reorder(:created_at, :id) }
end
