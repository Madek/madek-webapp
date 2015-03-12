module Presenters
  module Shared
    module MediaResources
      class MediaResourceRelations < Presenters::Shared::AppResource
        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def any?
          # parents can only be collections anyway
          parent_media_resources.collections.any? or
            sibling_media_resources.media_entries.any? or
            sibling_media_resources.collections.any? or
            sibling_media_resources.filter_sets.any?
        end

        def parent_media_resources
          Presenters::Shared::MediaResources::MediaResources.new \
            @user,
            collections: relational_collections(:parent)
        end

        def sibling_media_resources
          Presenters::Shared::MediaResources::MediaResources.new \
            @user,
            collections: relational_collections(:sibling)
        end

        private

        def relational_collections(kind)
          var = "@#{kind.to_s.pluralize}"
          instance_variable_get(var) \
            or instance_variable_set \
              var,
              @app_resource.send("#{kind}_collections_viewable_by_user", @user)
        end
      end
    end
  end
end
