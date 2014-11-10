class MediaEntryResource < Resource
  belongs_to :media_entry, foreign_key: 'id'

end
