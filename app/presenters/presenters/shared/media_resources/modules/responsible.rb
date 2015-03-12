module Presenters
  module Shared
    module MediaResources
      module Modules
        module Responsible
          def responsible
            @app_resource.responsible_user.person.to_s
          end
        end
      end
    end
  end
end
