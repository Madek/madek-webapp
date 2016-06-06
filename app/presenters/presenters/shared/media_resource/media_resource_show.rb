module Presenters
  module Shared
    module MediaResource
      class MediaResourceShow < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

        attr_accessor :collection_selection

        def initialize(app_resource, user, list_conf: nil)
          super(app_resource)
          @user = user
          @list_conf = list_conf
          @collection_selection = {}
        end

        def description
          @app_resource.description
        end

        def keywords
          @app_resource.keywords.map(&:to_s)
        end

        def type_underscore
          @app_resource.class.name.underscore
        end

      end
    end
  end
end
