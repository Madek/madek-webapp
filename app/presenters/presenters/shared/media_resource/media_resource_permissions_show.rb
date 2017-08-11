module Presenters
  module Shared
    module MediaResource
      class MediaResourcePermissionsShow < \
          Presenters::Shared::Resource::ResourcePermissionsShow

        include Presenters::Shared::MediaResource::Modules::Responsible

        def url
          send "permissions_#{@app_resource.class.model_name.singular}_path",
               id: @app_resource
        end

        # NOTE: defined here because only needed when editable
        def resource_url
          send "#{@app_resource.class.model_name.singular}_path",
               id: @app_resource
        end

        def permissions_url
          send "permissions_#{@app_resource.model_name.singular}_path",
               @app_resource
        end

        def fallback_url
          my_dashboard_path
        end

        def edit_permissions_url
          send "edit_permissions_#{@app_resource.model_name.singular}_path",
               @app_resource
        end

        def can_transfer
          auth_policy(@user, @app_resource).edit_transfer_responsibility?
        end
      end
    end
  end
end
