module Presenters
  module Shared
    module MediaResources
      class MediaResources < Presenter
        attr_reader :media_entries, :collections, :filter_sets

        def initialize(media_entries: [], collections: [], filter_sets: [])
          @media_entries = media_entries
          @collections = collections
          @filter_sets = filter_sets
        end
      end
    end
  end
end
