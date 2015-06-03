class MediaEntry < ActiveRecord::Base

  VIEW_PERMISSION_NAME = :get_metadata_and_previews
  EDIT_PERMISSION_NAME = :edit_metadata

  include Concerns::Collections::Siblings
  include Concerns::MediaEntries::Filters
  include Concerns::MediaResources
  include Concerns::MediaResources::Editability

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs, class_name: Arcs::CollectionMediaEntryArc
  has_many :parent_collections,
           through: :collection_media_entry_arcs,
           source: :collection

  default_scope { reorder(:created_at, :id) }
end
