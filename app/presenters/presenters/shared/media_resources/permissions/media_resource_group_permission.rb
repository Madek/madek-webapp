module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceGroupPermission < MediaResourceCommonPermission

          def subject
            Presenters::Groups::GroupIndex.new(@app_resource.group)
          end

        end
      end
    end
  end
end
