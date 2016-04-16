module Presenters
  module Previews
    class Preview < Presenters::Shared::AppResource

      # NOTE: some attributes only relate to images ([:thumbnail, :height, :width])
      delegate_to_app_resource(:media_type,
                               :content_type,
                               :height,
                               :width)

      def size_class
        @app_resource.thumbnail
      end

      def extension
        File.extname(@app_resource.filename).split('.').last
      end

      def url
        prepend_url_context preview_path(@app_resource)
      end

    end
  end
end
