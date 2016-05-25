module Presenters
  module MediaEntries
    class MediaEntryEditContextMetaData \
        < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      attr_reader :context_id

      def initialize(app_resource, user, context_id)
        fail 'TypeError!' unless app_resource.is_a?(MediaEntry)
        @app_resource = app_resource
        @user = user
        @list_conf = {}
        @media_file = Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
        @context_id = context_id
      end

    end
  end
end
