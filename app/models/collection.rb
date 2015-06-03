class Collection < ActiveRecord::Base

  VIEW_PERMISSION_NAME = :get_metadata_and_previews
  EDIT_PERMISSION_NAME = :edit_metadata_and_relations

  include Concerns::Collections::Siblings
  include Concerns::MediaResources
  include Concerns::MediaResources::Editability

  #################################################################################

  has_many :collection_media_entry_arcs,
           class_name: Arcs::CollectionMediaEntryArc

  has_many :collection_collection_arcs_as_parent,
           class_name: Arcs::CollectionCollectionArc,
           foreign_key: :parent_id

  has_many :collection_collection_arcs_as_child,
           class_name: Arcs::CollectionCollectionArc,
           foreign_key: :child_id

  has_many :collection_filter_set_arcs,
           class_name: Arcs::CollectionFilterSetArc

  has_many :media_entries, through: :collection_media_entry_arcs do

    def highlights
      where('collection_media_entry_arcs.highlight = ?', true)
    end

    def cover
      find_by('collection_media_entry_arcs.cover = ?', true)
    end

  end

  has_many :collections,
           through: :collection_collection_arcs_as_parent,
           source: :child
  has_many :parent_collections,
           through: :collection_collection_arcs_as_child,
           source: :parent
  has_many :filter_sets, through: :collection_filter_set_arcs

  #################################################################################

  scope :by_title, lambda{ |title|
    joins(:meta_data)
      .where(meta_data: { meta_key_id: 'madek_core:title' })
      .where('string ILIKE :title', title: "%#{title}%")
      .order(:created_at, :id)
  }

  default_scope { reorder(:created_at, :id) }
end
