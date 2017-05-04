# VIEW presenter!
module Presenters
  module MediaEntries
    class MediaEntryBrowse < Presenters::Shared::AppResourceWithUser

      def entry
        Presenters::MediaEntries::MediaEntryIndex.new(@app_resource, @user)
      end

      def entry_meta_data
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
          .dump(sparse_spec: { entry_summary_context: {} })
      end

      def browse_resources
        Presenters::MediaEntries::Modules::MediaEntryBrowse
          .new(@app_resource, @user)
      end

    end
  end
end
