module Presenters
  module People
    class PersonIndexWithUsageCount < Presenters::People::PersonCommon

      def initialize(app_resource)
        super(app_resource)
      end

      delegate_to_app_resource :usage_count
    end
  end
end
