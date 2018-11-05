module Presenters
  module Roles
    class RoleIndex < Presenters::Roles::RoleCommon
      delegate_to_app_resource :id, :term

      def initialize(app_resource)
        super(app_resource)
      end

    end
  end
end
