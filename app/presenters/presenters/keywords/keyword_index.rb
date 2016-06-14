module Presenters
  module Keywords
    class KeywordIndex < Presenters::Keywords::KeywordCommon

      def initialize(app_resource)
        super(app_resource)
        @usage_count = 0
      end

    end
  end
end
