module Presenters
  module IoMappings
    class IoMappingCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:meta_key_id,
                               :key_map)
    end
  end
end
