module Presenters
  module Shared
    module MediaResources
      class MediaResourceIndex < Presenters::Shared::AppResource
        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def privacy_status
          public_status or shared_status or private_status
        end

        private

        def public_status
          :public if @app_resource.public?
        end

        def shared_status
          model_name = @app_resource.class.model_name
          :shared if \
            @user.send("entrusted_#{model_name.singular}_to_users?",
                       @app_resource) \
            or @user.send("entrusted_#{model_name.singular}_to_groups?",
                          @app_resource) \
            or @app_resource.entrusted_to_user?(@user)
        end

        def private_status
          :private
        end
      end
    end
  end
end
