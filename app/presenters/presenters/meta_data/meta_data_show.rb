module Presenters
  module MetaData

    class MetaDataShow < Presenters::MetaData::MetaDataCommon

      private

      def fetch_relevant_meta_data
        return @meta_data if @meta_data
        @meta_data = @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: { id: relevant_vocabularies })
        @meta_data
      end

    end
  end
end
