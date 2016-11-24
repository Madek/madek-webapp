module Presenters
  module Shared
    module MediaResource
      class MediaResourceRelations < Presenters::Shared::AppResource
        def initialize(
          app_resource,
          user,
          user_scopes,
          list_conf: nil,
          load_meta_data: false)
          super(app_resource)
          @user = user
          @user_scopes = user_scopes
          @list_conf = list_conf
          @load_meta_data = load_meta_data
        end

        def any?
          parent_collections.resources.any? or
            sibling_collections.any?
        end

        def parent_collections
          Presenters::Shared::MediaResource::MediaResources.new(
            @user_scopes[:parent_collections],
            @user,
            can_filter: false,
            list_conf: @list_conf)
        end

        def sibling_collections
          # TODO: exclusion of self from siblings should be done
          # in the model?!
          Presenters::Shared::MediaResource::MediaResources.new(
            @user_scopes[:sibling_collections]
              .where.not(collections: { id: @app_resource.id }),
            @user,
            can_filter: false,
            list_conf: @list_conf)
        end
      end
    end
  end
end
