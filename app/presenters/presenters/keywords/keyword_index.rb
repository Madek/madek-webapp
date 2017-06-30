module Presenters
  module Keywords
    class KeywordIndex < Presenters::Keywords::KeywordCommon

      delegate_to_app_resource :meta_key_id

      def initialize(app_resource)
        super(app_resource)
        @usage_count = 0
      end

    end
  end
end
