module Presenters
  module MediaEntries
    class MediaEntryEditMetaData \
        < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def meta_data
        Presenters::MetaData::MetaDataEdit.new(@app_resource, @user)
      end

    end
  end
end
