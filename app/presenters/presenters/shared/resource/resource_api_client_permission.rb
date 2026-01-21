module Presenters
  module Shared
    module Resource
      class ResourceApiClientPermission < Presenters::Shared::AppResourceWithUser

        def subject
          a = @app_resource.api_client
          Pojo.new(
            uuid: a.id,
            login: a.login,
            description: a.description,
            tooltip_text: localize(a.permission_descriptions),
            _type: 'ApiClientIndex'
          )
        end
      end
    end
  end
end
