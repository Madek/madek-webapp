module Presenters
  module MediaEntries
    class MediaEntryEdit < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::MediaEntries::Modules::MediaEntryMetaData

    end
  end
end
