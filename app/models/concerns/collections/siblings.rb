module Concerns
  module Collections
    module Siblings

      def sibling_collections
        Collection
          .joins(:collection_collection_arcs_as_child)
          .where(collection_collection_arcs:
                   { parent_id: parent_collections.select(:id) })
      end

    end
  end
end
