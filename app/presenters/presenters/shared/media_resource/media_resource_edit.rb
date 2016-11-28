module Presenters
  module Shared
    module MediaResource
      # FIXME: this should inherit directly from Presenter (it's not a Resource!)
      class MediaResourceEdit < Presenters::Shared::AppResource

        include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def meta_data
          Presenters::MetaData::MetaDataEdit.new(@app_resource, @user)
        end

        def published
          if @app_resource.class == MediaEntry
            @app_resource.is_published
          else
            true
          end
        end

        def resource
          presenter_by_class(@app_resource.class).new(@app_resource, @user)
        end
      end
    end
  end
end
