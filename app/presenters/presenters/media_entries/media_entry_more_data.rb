module Presenters
  module MediaEntries
    class MediaEntryMoreData < Presenters::Shared::AppResource

      def initialize(app_resource)
        super(app_resource)
        @media_file = @app_resource.media_file
      end

      def responsible
        return unless (responsible = @app_resource.try(:responsible_user))
        ::Presenters::Users::UserIndex.new(responsible)
      end

      def responsible_user_uuid
        @app_resource.responsible_user.id if @app_resource.responsible_user
      end

      def file_information
        return unless @media_file
        @media_file
          .meta_data
          .transform_values do |val| # Filter out binary data (breaks UI)
            begin; val.to_json; rescue; next '(Binary or unknown data)'; end
            val
          end
          .to_a
          .unshift ['Filename', filename]
      end

      def importer
        return unless (uploader = @app_resource.media_file.uploader)
        Presenters::People::PersonIndex.new(uploader.person)
      end

      def import_date
        return unless @media_file
        @media_file.created_at
          .in_time_zone(AppSetting.first.time_zone)
          .strftime('%d.%m.%Y')
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
          es.created_at
            .in_time_zone(AppSetting.first.time_zone)
            .strftime('%d.%m.%Y, %H:%M'),
          ::Presenters::Users::UserIndex.new(es.user)
        ]
      end

      def filename
        @media_file.filename if @media_file
      end
    end
  end
end
