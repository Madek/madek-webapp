module Presenters
  module Shared
    module Modules
      module PartOfWorkflow
        extend ActiveSupport::Concern

        included do
          delegate_to_app_resource :part_of_workflow?, as_private_method: true
        end

        def workflow
          if part_of_workflow?(active: true)
            Presenters::Workflows::WorkflowEdit.new(@app_resource.workflow,
                                                    @user)
          end
        end
      end
    end
  end
end
