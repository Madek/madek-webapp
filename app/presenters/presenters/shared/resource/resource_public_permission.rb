module Presenters
  module Shared
    module Resource
      class ResourcePublicPermission < Presenters::Shared::AppResource
        def tooltip_text
          AppSetting.first.permission_public_description
        end
      end
    end
  end
end
