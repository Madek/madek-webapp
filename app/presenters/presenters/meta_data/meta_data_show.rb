module Presenters
  module MetaData

    class MetaDataShow < Presenters::MetaData::MetaDataCommon

      private

      def fetch_relevant_meta_data
        @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: { id: relevant_vocabularies })
      end

    end
  end
end
