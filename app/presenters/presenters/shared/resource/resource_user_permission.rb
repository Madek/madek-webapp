module Presenters
  module Shared
    module Resource
      class ResourceUserPermission < Presenters::Shared::AppResourceWithUser

        def subject
          case
          when @app_resource.user
            Presenters::Users::UserIndex.new(@app_resource.user)
          when @app_resource&.delegation
            Presenters::Delegations::DelegationIndex.new(@app_resource.delegation)
          end
        end

      end
    end
  end
end
