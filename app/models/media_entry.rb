class MediaEntry < ActiveRecord::Base

  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::EditSessions
  include Concerns::Permissions
  include Concerns::Users::Responsible
  include Concerns::Users::Creator
  include Concerns::Keywords

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs
  has_many :collections, through: :collection_media_entry_arcs

  default_scope { reorder(:created_at, :id) }
end
