module Presenters
  module Roles
    class RoleIndex < Presenters::Roles::RoleCommon
      delegate_to_app_resource :id, :term

      def initialize(app_resource, meta_datum = nil)
        super(app_resource)

        @meta_datum = meta_datum
      end

      def position
        if @meta_datum
          @meta_datum.position
        else
          0
        end
      end
    end
  end
end
