module Presenters
  module Shared
    module MediaResources
      class MediaResourceIndex < Presenter

        def privacy_status
          public_status or shared_status or private_status
        end

        private

        def public_status
          :public if @resource.public?
        end

        def shared_status
          model_name = @resource.class.model_name
          :shared if \
            @user.send("entrusted_#{model_name.singular}_to_users?",
                       @resource) \
            or @user.send("entrusted_#{model_name.singular}_to_groups?",
                          @resource) \
            or @resource.entrusted_to_user?(@user)
        end

        def private_status
          :private
        end
      end
    end
  end
end
