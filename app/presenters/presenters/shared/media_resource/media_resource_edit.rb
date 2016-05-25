module Presenters
  module Shared
    module MediaResource
      class MediaResourceEdit < Presenters::Shared::AppResource

        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def meta_data
          Presenters::MetaData::MetaDataEdit.new(@app_resource, @user)
        end
      end
    end
  end
end
