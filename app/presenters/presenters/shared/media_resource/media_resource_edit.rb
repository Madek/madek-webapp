module Presenters
  module Shared
    module MediaResource
      # FIXME: this should inherit directly from Presenter (it's not a Resource!)
      class MediaResourceEdit < Presenters::Shared::AppResource

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

        def title
          @app_resource.title
        end

        def url
          path_variable = @app_resource.class.name.underscore + '_path'
          path = self.send(path_variable, @app_resource)
          prepend_url_context path
        end
      end
    end
  end
end
