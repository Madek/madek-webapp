module Presenters
  module Shared
    module Resource
      class ResourceUserPermission < Presenters::Shared::AppResourceWithUser

        def subject
          Presenters::Users::UserIndex.new(@app_resource.user)
        end

      end
    end
  end
end
