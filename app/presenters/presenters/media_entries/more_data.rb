module Presenters
  module MediaEntries
    class MoreData < Presenters::Shared::AppResource
      include Presenters::Shared::MediaResources::Modules::Responsible

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
        @app_resource.media_file.uploader.person.to_s
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
        "#{es.user.person} / #{es.created_at.strftime('%d.%m.%Y, %H:%M')}"
      end

      def filename
        @media_file.filename
      end
    end
  end
end
