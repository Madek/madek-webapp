module Presenters
  module People
    class PersonIndexForRoles < PersonIndex

      attr_reader :role

      # app_resource is MetaDatum::People instance
      def initialize(app_resource)
        super(app_resource.person)

        set_role(app_resource)
      end

      private

      def set_role(app_resource)
        @role = if app_resource.role
          Presenters::Roles::RoleIndex.new(app_resource.role)
        end
      end
    end
  end
end
