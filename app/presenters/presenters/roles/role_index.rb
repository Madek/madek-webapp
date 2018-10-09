module Presenters
  module Roles
    class RoleIndex < Presenters::Roles::RoleCommon

      delegate_to_app_resource :meta_key_id

      def initialize(app_resource)
        super(app_resource)
        @usage_count = 0
      end

      def values
        %w(foo bar)
      end

    end
  end
end
