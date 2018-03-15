module Modules
  module Resources
    module Share
      extend ActiveSupport::Concern

      def share
        resource = get_authorized_resource
        @get = Presenters::Shared::MediaResource::ShareResource.new(
          resource,
          current_user,
          settings.madek_external_base_url
        )
        respond_with(@get)
      end
    end
  end
end
