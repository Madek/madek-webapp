module Presenters
  module MetaData

    class MetaDataShow < Presenters::MetaData::ResourceMetaData

      private

      def fetch_relevant_meta_data
        # NOTE: don't filter by enabled to no hide existing data!
        #       .where(is_enabled_for_media_entries: true)
        @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: { id: relevant_vocabularies.map(&:id) })
      end

      def relevant_vocabularies
        visible_vocabularies(@user)
      end

    end
  end
end
