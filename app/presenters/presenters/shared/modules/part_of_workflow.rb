module Presenters
  module Shared
    module Modules
      module PartOfWorkflow
        extend ActiveSupport::Concern

        included do
          delegate_to_app_resource :part_of_workflow?
        end

        def workflow
          if part_of_workflow?
            Presenters::Workflows::WorkflowEdit.new(@app_resource.workflow,
                                                    @user)
          end
        end
      end
    end
  end
end
