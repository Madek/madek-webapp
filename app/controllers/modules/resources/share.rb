module Modules
  module Resources
    module Share
      extend ActiveSupport::Concern

      def share
        resource = get_authorized_resource
        @get = Presenters::Shared::MediaResource::ShareResource.new(
          resource,
          current_user,
          request.base_url
        )
        respond_with(@get)
      end
    end
  end
end
