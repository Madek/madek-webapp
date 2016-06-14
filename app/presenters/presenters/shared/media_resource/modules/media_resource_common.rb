module Presenters
  module Shared
    module MediaResource
      module Modules
        module MediaResourceCommon
          extend ActiveSupport::Concern
          include Presenters::Shared::MediaResource::Modules::Responsible

          def title
            @app_resource.title
          end

          def created_at_pretty
            @app_resource.created_at.strftime('%d.%m.%Y')
          end

          def destroyable
            false
          end

          def editable
            false
          end

        end
      end
    end
  end
end
