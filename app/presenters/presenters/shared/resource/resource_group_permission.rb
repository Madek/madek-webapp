module Presenters
  module Shared
    module Resource
      class ResourceGroupPermission < Presenters::Shared::AppResource

        def subject
          Presenters::Groups::GroupIndex.new(@app_resource.group)
        end

      end
    end
  end
end
