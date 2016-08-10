module Presenters
  module Shared
    module MediaResource
      class BatchMediaResourceEdit < Presenters::Shared::AppResource

        def initialize(app_resource, user, usable_meta_keys_map)
          super(app_resource)
          @user = user
          @usable_meta_keys_map = usable_meta_keys_map
        end

        def meta_data
          Presenters::MetaData::BatchMetaDataEdit.new(
            @app_resource,
            @user,
            @usable_meta_keys_map
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
