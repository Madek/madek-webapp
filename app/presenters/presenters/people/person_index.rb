module Presenters
  module People
    class PersonIndex < PersonCommon
      def initialize(app_resource, count = nil)
        super(app_resource)
      end

      delegate_to_app_resource :first_name, :last_name, :pseudonym, :identification_info
    end
  end
end
