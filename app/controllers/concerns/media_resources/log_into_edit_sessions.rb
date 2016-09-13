module Concerns
  module MediaResources
    module LogIntoEditSessions
      def log_into_edit_sessions!(resource)
        EditSession.create! Hash[:user, current_user,
                                 resource.model_name.singular, resource]
      end
    end
  end
end
