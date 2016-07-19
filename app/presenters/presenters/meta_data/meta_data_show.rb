module Presenters
  module MetaData

    class MetaDataShow < Presenters::MetaData::ResourceMetaData

      def by_vocabulary
        @by_vocabulary ||=
          _by_vocabulary(fetch_visible_meta_data)
      end

      private

      def fetch_visible_meta_data
        # NOTE: don't filter by enabled to no hide existing data!
        #       .where(is_enabled_for_media_entries: true)
        @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: { id: visible_vocabularies_for_user.map(&:id) })
      end
    end
  end
end
