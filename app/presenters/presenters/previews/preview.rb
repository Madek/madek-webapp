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
        if @app_resource.hls?
          return hls_file_preview_path(
            @app_resource,
            path: 'master.m3u8',
            accessToken: @access_token
          )
        end

        # NOTE: set `format` to force the url to have a nice extension,
        # as a workaround when the HTTP content-type header is not handled correctly by clients
        preview_path(@app_resource, format: self.extension, accessToken: @access_token)
      end

      def download_url
        if @app_resource.hls?
          hls_package_preview_path(@app_resource, accessToken: @access_token)
        elsif @app_resource.content_type == 'video/mp4'
          preview_path(
            @app_resource,
            format: extension,
            accessToken: @access_token,
            download: 'yes'
          )
        end
      end

      def renditions
        return unless @app_resource.hls?

        HlsPackage.new(@app_resource.media_file).renditions.map do |rendition|
          {
            height: rendition[:height],
            width: rendition[:width],
            url: hls_file_preview_path(
              @app_resource,
              path: rendition[:media_file],
              accessToken: @access_token,
              download: 'yes'
            )
          }
        end
      rescue HlsPackage::InvalidPackage, Errno::ENOENT
        []
      end
    end
  end
end
