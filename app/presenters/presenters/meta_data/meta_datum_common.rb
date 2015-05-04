module Presenters
  module MetaData
    class MetaDatumCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:meta_key_id,
                               :type,
                               :value,
                               :media_entry_id,
                               :collection_id,
                               :filter_set_id)

      def values
        value = @app_resource.value
        if ApplicationHelper.ar_collection_proxy?(value)
          value.map(&:id)
        else
          [value]
        end
      end
    end
  end
end
