module Presenters
  module IoMappings
    class IoMappingCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:meta_key_id)

      def key_map
        @app_resource.exiftool_keys.join(', ')
      end
    end
  end
end
