module Presenters
  module People
    class PersonIndexForRoles < PersonIndex

      attr_reader :position, :role

      def initialize(app_resource)
        super(app_resource.person)

        set_position(app_resource)
        set_role(app_resource)
      end

      private

      def set_position(app_resource)
        @position = app_resource.position
      end

      def set_role(app_resource)
        @role = if app_resource.role
          Presenters::Roles::RoleIndex.new(app_resource.role, app_resource)
        else
          nil
        end
      end
    end
  end
end
