module Presenters
  module Roles
    class RoleIndex < Presenters::Roles::RoleCommon
      delegate_to_app_resource :id, :term
    end
  end
end
