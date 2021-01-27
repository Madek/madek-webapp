module Presenters
  module Workflows
    class WorkflowIndex < Presenter
      def initialize(user)
        @user = user
      end

      def by_status
        @user.with_delegated_workflows
        .order('updated_at DESC')
        .map { |w| Presenters::Workflows::WorkflowCommon.new(w, @user) }
        .group_by(&:status)
      end
    end
  end
end
