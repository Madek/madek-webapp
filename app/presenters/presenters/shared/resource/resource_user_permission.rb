module Presenters
  module Shared
    module Resource
      class ResourceUserPermission < Presenters::Shared::AppResource

        def subject
          Presenters::Users::UserIndex.new(@app_resource.user)
        end

      end
    end
  end
end
