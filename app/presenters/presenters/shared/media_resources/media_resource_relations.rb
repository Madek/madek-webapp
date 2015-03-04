module Presenters
  module Shared
    module MediaResources
      class MediaResourceRelations < Presenter
        def initialize(resource, user)
          @resource = resource
          @user = user
        end

        def any?
          parent_collections.any? or
            sibling_media_resources.media_entries.any? or
            sibling_media_resources.collections.any? or
            sibling_media_resources.filter_sets.any?
        end

        def parent_collections
          relational_collections(:parent)
        end

        def sibling_media_resources
          Presenters::Shared::MediaResources::MediaResources.new \
            collections: relational_collections(:sibling)
        end

        private

        def relational_collections(kind)
          var = "@#{kind.to_s.pluralize}"
          instance_variable_get(var) \
            or instance_variable_set \
              var,
              @resource.send("#{kind}_collections_viewable_by_user", @user)
                .map { |c| Presenters::Collections::CollectionIndex.new(c, @user) }
        end
      end
    end
  end
end
