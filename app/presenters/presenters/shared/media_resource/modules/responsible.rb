module Presenters
  module Shared
    module MediaResource
      module Modules
        module Responsible
          def responsible
            return unless (responsible = @app_resource.try(:responsible_user))
            if responsible.is_deactivated
              ::Presenters::Users::UserIndex.new(responsible)
            else
              ::Presenters::People::PersonIndex.new(responsible.person)
            end
          end

          def responsible_user_uuid
            @app_resource.responsible_user.id if @app_resource.responsible_user
          end
        end
      end
    end
  end
end
