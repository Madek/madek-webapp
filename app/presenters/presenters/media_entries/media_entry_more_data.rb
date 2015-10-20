module Presenters
  module MediaEntries
    class MediaEntryMoreData < Presenters::Shared::AppResource
      include Presenters::Shared::MediaResource::Modules::Responsible

      def initialize(app_resource)
        super(app_resource)
        @media_file = @app_resource.media_file
      end

      def file_information
        @media_file
          .meta_data
          .to_a
          .unshift ['Filename', filename]
      end

      def importer
        ::Presenters::People::PersonIndex.new \
          @app_resource.media_file.uploader.person
      end

      def import_date
        @app_resource.media_file.created_at.strftime('%d.%m.%Y')
      end

      def activity_log
        @app_resource
          .edit_sessions
          .limit(5)
          .map { |es| format_edit_session(es) }
      end

      private

      def format_edit_session(es)
        [
          es.created_at.strftime('%d.%m.%Y, %H:%M'),
          ::Presenters::People::PersonIndex.new(es.user.person)
        ]
      end

      def filename
        @media_file.filename
      end
    end
  end
end
