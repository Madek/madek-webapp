module Presenters
  module MediaEntries
    class MediaEntryEditMetaData \
        < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::MediaEntries::Modules::MediaEntryCommon
    end
  end
end