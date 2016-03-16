module Presenters
  module Previews
    class Preview < Presenters::Shared::AppResource

      delegate_to_app_resource(:media_type,
                               :content_type)

      def initialize(app_resource)
        super(app_resource)

        # some attributes only relate to images
        if app_resource.media_type == :image
          delegate_to_app_resource(:thumbnail, :height, :width)
        end
      end

      def extension
        File.extname(@app_resource.filename).split('.').last
      end

      def url
        prepend_url_context_fucking_rails preview_path(@app_resource)
      end

    end
  end
end
