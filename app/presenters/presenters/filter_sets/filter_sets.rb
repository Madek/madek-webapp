module Presenters
  module FilterSets
    class FilterSets < Presenters::Shared::MediaResources::MediaResources

      private

      def indexify(filter_sests)
        indexify_with_presenter(filter_sests,
                                Presenters::FilterSets::FilterSetIndex)
      end
    end
  end
end
