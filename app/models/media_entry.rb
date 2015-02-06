class MediaEntry < ActiveRecord::Base

  include Concerns::EditSessions
  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::MetaData
  include Concerns::PermissionsAssociations
  include Concerns::Users::Creator
  include Concerns::Users::Responsible

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs, class_name: Arcs::CollectionMediaEntryArc
  has_many :collections, through: :collection_media_entry_arcs

  default_scope { reorder(:created_at, :id) }
end
