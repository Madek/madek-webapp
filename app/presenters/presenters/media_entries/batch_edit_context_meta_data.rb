module Presenters
  module MediaEntries
    class BatchEditContextMetaData < Presenter

      attr_reader :context_id, :return_to

      def initialize(media_entries, user, context_id: nil, return_to:)
        @entries = media_entries
        @user = user
        @context_id = context_id
        @return_to = return_to
      end

      def resources
        Presenters::Shared::MediaResource::IndexResources.new(@user, @entries)
      end

      def batch_entries
        @entries.map do |entry|
          Presenters::Shared::MediaResource::MediaResourceEdit.new(entry, @user)
        end
      end

      def meta_data
        Presenters::MetaData::MetaDataEdit.new(@entries[0], @user)
      end

      def meta_meta_data
        Presenters::MetaData::MetaMetaDataEdit.new(@user, @entries[0].class)
      end

      def submit_url
        batch_meta_data_media_entries_path
      end

    end
  end
end
