class CollectionMediaEntryArc < ActiveRecord::Base
  belongs_to :collection
  belongs_to :media_entry
end
