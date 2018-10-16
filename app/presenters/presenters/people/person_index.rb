module Presenters
  module People
    class PersonIndex < PersonCommon

      def initialize(app_resource, count = nil)
        super(app_resource)
        @usage_count = count
      end

      delegate_to_app_resource :first_name, :last_name, :pseudonym

      attr_reader :usage_count

    end
  end
end
