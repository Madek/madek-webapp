module Presenters
  module Shared
    module Resource
      class ResourceGroupPermission < Presenters::Shared::AppResourceWithUser

        def subject
          Presenters::Groups::GroupCommon.new(@app_resource.group, @user)
        end

      end
    end
  end
end
