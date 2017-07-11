module Presenters
  module Shared
    module MediaResource
      class BatchMediaResourceEdit < Presenters::Shared::AppResourceWithUser

        def meta_data
          Presenters::MetaData::MetaDataEdit.new(
            @app_resource,
            @user
          )
        end

        def published
          if @app_resource.class == MediaEntry
            @app_resource.is_published
          else
            true
          end
        end
      end
    end
  end
end
