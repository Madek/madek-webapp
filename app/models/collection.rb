class Collection < ActiveRecord::Base

  include Concerns::EditSessions
  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::MetaData
  include Concerns::PermissionsAssociations
  include Concerns::Users::Creator
  include Concerns::Users::Responsible

  #################################################################################

  has_many :collection_media_entry_arcs,
           class_name: Arcs::CollectionMediaEntryArc

  has_many :collection_collection_arcs,
           class_name: Arcs::CollectionCollectionArc,
           foreign_key: :parent_id

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

  has_many :collections, through: :collection_collection_arcs, source: :child
  has_many :filter_sets, through: :collection_filter_set_arcs

  #################################################################################

  scope :by_title, lambda{ |title|
    joins(:meta_data).where(meta_data: { meta_key_id: 'madek:core:title' })
    .where('string ILIKE :title', title: "%#{title}%").order(:created_at, :id)
  }

  default_scope { reorder(:created_at, :id) }
end
