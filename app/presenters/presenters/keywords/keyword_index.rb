module Presenters
  module Keywords
    class KeywordIndex < Presenters::Keywords::KeywordCommon

      def initialize(app_resource, count = nil)
        super(app_resource)
        @usage_count = count
      end

      attr_reader :usage_count
    end
  end
end
