module Presenters
  module Previews
    class Preview < Presenters::Shared::AppResource

      # NOTE: some attributes only relate to
      # - images ([:thumbnail, :height, :width])
      # - video ([:conversion_profile])
      delegate_to_app_resource(:media_type,
                               :content_type,
                               :height,
                               :width)

      def initialize(app_resource, access_token = nil)
        super(app_resource)
        @access_token = access_token
        if @app_resource.media_type == 'video'
          define_singleton_method :profile do
            @app_resource.conversion_profile
          end
        end
      end

      def size_class
        @app_resource.thumbnail
      end

      def extension
        File.extname(@app_resource.filename).split('.').last
      end

      def url
        # NOTE: set `format` to force the url to have a nice extension,
        # as a workaround when the HTTP content-type header is not handled correctly by clients
        preview_path(@app_resource, format: self.extension, accessToken: @access_token)
      end
    end
  end
end
