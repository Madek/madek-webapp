module Presenters
  module Shared
    module MediaResource
      module Modules
        module MediaResourceCommon
          extend ActiveSupport::Concern
          include Presenters::Shared::MediaResource::Modules::Responsible
          include Presenters::Shared::MediaResource::Modules::URLHelpers

          def title
            @app_resource.title
          end

          def created_at_pretty
            @app_resource.created_at.strftime('%d.%m.%Y')
          end

          def favored
            @user.present? and @app_resource.favored?(@user)
          end

          # TODO: rename/move to view presenter
          def favorite_policy
            policy(@user).favor?
          end
        end
      end
    end
  end
end
