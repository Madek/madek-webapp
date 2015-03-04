module Presenters
  module Shared
    module MediaResources
      class MediaResources < Presenter
        attr_reader :media_entries, :collections, :filter_sets

        # TODO: rewrite to use ruby 2.0 keyword syntax
        # can't be done now because of parser error of flog
        # or in worse case disable flog for this case
        def initialize(media_resources = {})
          @media_entries = media_resources[:media_entries]
          @collections = media_resources[:collections]
          @filter_sets = media_resources[:filter_sets]
        end
      end
    end
  end
end
