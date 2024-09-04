module Modules
  module Batch
    module BatchLogIntoEditSessions
      extend ActiveSupport::Concern
      include MediaResources::LogIntoEditSessions

      def batch_log_into_edit_sessions!(resources)
        resources.each { |resource| log_into_edit_sessions! resource }
      end
    end
  end
end
