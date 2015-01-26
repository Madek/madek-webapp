module Arcs
  class CollectionFilterSetArc < ActiveRecord::Base
    belongs_to :collection
    belongs_to :filter_set
  end
end
