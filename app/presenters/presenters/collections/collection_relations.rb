module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResources::MediaResourceRelations

      include Presenters::Shared::MediaResources::Modules::\
              MediaResourcesHelpers

      def any?
        super or
          child_media_resources.media_entries.any? or
          child_media_resources.collections.any? or
          child_media_resources.filter_sets.any?
      end

      alias_method :child_media_resources,
                   :standard_media_resources
    end
  end
end
