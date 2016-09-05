module Presenters
  module Shared
    module MediaResource
      class MediaResourceIndex < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

        def initialize(app_resource, user, list_conf: nil, load_meta_data: false)
          super(app_resource)
          @user = user
          @list_conf = list_conf
          @load_meta_data = load_meta_data
        end

        def index_meta_data
          return unless @load_meta_data
          Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
        end

        # def large_image
        #   binding.pry
        #   return unless @load_meta_data
        #   media_file.previews[images.large.url || image_url
        # end

        private

        def create_presenter(resources)
          Presenters::Shared::MediaResource::IndexResources.new(@user, resources)
        end

      end
    end
  end
end
