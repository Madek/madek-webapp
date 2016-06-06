module Presenters
  module MediaEntries
    class MediaEntryAskDelete < Presenters::MediaEntries::MediaEntryShow

      def initialize(user, media_entry, user_scopes, resource_list_params)
        super(media_entry, user, user_scopes, list_conf: resource_list_params)
      end

      def submit_url
        media_entry_path(@app_resource)
      end

      def cancel_url
        media_entry_path(@app_resource)
      end
    end
  end
end
