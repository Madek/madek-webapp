module Presenters
  module Collections
    class Collections < Presenters::Shared::MediaResources::MediaResources

      private

      def indexify(collections)
        indexify_with_presenter(collections,
                                Presenters::Collections::CollectionIndex)
      end
    end
  end
end
