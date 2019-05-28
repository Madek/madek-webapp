module Presenters
  module Workflows
    class WorkflowIndex < Presenter
      def initialize(user)
        @user = user
      end

      def list
        @user.workflows.map { |w| Presenters::Workflows::WorkflowCommon.new(w, @user) }
      end
    end
  end
end
