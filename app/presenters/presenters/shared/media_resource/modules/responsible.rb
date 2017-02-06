module Presenters
  module Shared
    module MediaResource
      module Modules
        module Responsible
          def responsible
            ::Presenters::People::PersonIndex.new \
              @app_resource.responsible_user.person
          end

          def responsible_user_uuid
            @app_resource.responsible_user.id if @app_resource.responsible_user
          end
        end
      end
    end
  end
end
