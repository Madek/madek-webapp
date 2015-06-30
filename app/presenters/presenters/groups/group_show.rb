module Presenters
  module Groups
    class GroupShow < GroupCommon
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def entrusted_media_resources
        Presenters::Shared::MediaResources::MediaResources.new \
          @user,
          media_resources: MediaResource.entrusted_to_group(@app_resource)
      end
    end
  end
end
