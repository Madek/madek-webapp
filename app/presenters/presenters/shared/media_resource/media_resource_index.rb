module Presenters
  module Shared
    module MediaResource
      class MediaResourceIndex < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus
        include Presenters::Shared::Clipboard

        def initialize(app_resource, user, list_conf: nil, load_meta_data: false)
          super(app_resource)
          @user = user
          @list_conf = list_conf
          @load_meta_data = load_meta_data
        end

        def list_meta_data
          layout_is_list = @list_conf && @list_conf[:layout] == 'list'

          return unless layout_is_list

          Presenters::MediaResources::MediaResourceListMetadata.new(
            @app_resource, @user)
        end

        def on_clipboard
          return unless @user
          clipboard = clipboard_collection(@user)
          return unless clipboard
          if @app_resource.class == MediaEntry
            clipboard.media_entries.include?(@app_resource)
          elsif @app_resource.class == Collection
            clipboard.collections.include?(@app_resource)
          end
        end

        private

        def create_presenter(resources)
          Presenters::Shared::MediaResource::IndexResources.new(@user, resources)
        end

      end
    end
  end
end
