class CollectionResource < Resource
  belongs_to :collection, foreign_key: 'id'
end
