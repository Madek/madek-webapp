module Presenters
  module MediaEntries
    class MediaEntryIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::MediaEntries::Modules::MediaEntryPreviews

      def image_url
        img = preview_helper(type: :image, size: :medium)
        img.present? ? img.url : generic_thumbnail_url
      end

    end
  end
end
