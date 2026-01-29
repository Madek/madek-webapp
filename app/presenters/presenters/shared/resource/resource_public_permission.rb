module Presenters
  module Shared
    module Resource
      class ResourcePublicPermission < Presenters::Shared::AppResource
        def tooltip_text
          localize(AppSetting.first.permission_public_descriptions)
        end
      end
    end
  end
end
