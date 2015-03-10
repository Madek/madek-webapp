module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceUserPermission < MediaResourceCommonPermission
          def initialize(resource)
            @resource = resource
          end

          def person_name
            @resource.user.person.to_s
          end

          delegate :edit_permissions, to: :@resource
        end
      end
    end
  end
end
