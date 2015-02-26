module Presenters
  module Shared
    module Resources
      class ResourcesThumb < Presenter
        include Presenters::Shared::Resources::Modules::URLHelpers

        def initialize(resource, user)
          @resource = resource
          @user = user
        end

        def title
          @resource.title
        end

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
