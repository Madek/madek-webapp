module Presenters
  module Shared
    module MediaResources
      module Modules
        module Responsible
          def responsible
            ::Presenters::People::PersonIndex.new \
              @app_resource.responsible_user.person
          end
        end
      end
    end
  end
end
