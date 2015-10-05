module Presenters
  module Shared
    module MediaResources
      class MediaResourceEdit < Presenters::Shared::AppResource

        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

      end
    end
  end
end
