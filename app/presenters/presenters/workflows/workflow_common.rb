WORKFLOW_STATES = { IN_PROGRESS: :IN_PROGRESS, FINISHED: :FINISHED }.freeze # NOTE: fake ruby enums

module Presenters
  module Workflows
    class WorkflowCommon < Presenters::Shared::AppResourceWithUser
      delegate_to_app_resource :name

      def status
        @app_resource.is_active ? WORKFLOW_STATES[:IN_PROGRESS] : WORKFLOW_STATES[:FINISHED]
      end

      def associated_collections
        @app_resource.collections.map do |col|
          Presenters::Collections::CollectionIndex.new(col, @user)
        end
      end

      def actions
        {
          edit: { url: edit_my_workflow_path(@app_resource) },
          update: { url: my_workflow_path(@app_resource), method: 'PATCH' }
        }
      end

      private

      def common_permissions
        @app_resource.configuration['common_permissions'].map do |permission, value|
          [
            permission,
            case permission
            when 'responsible'
              presenterify(determine_user_or_delegation(value))
            when 'write', 'read'
              presenterify(
                value
                  .group_by { |v| v['type'] }
                  .map do |class_name, values|
                    class_name.constantize.where(id: values.map { |v| v['uuid'] })
                  end.flatten
              )
            when 'read_public'
              value
            end
          ]
        end.to_h
      end

      def determine_user_or_delegation(id)
        User.find(id)
      rescue ActiveRecord::RecordNotFound
        Delegation.find(id)
      end

      def presenterify(obj)
        return obj.map { |item| presenterify(item) } if obj.is_a?(Array)

        case obj
        when User
          Presenters::Users::UserIndex.new(obj)
        when Delegation
          Presenters::Delegations::DelegationIndex.new(obj)
        when Group, InstitutionalGroup
          Presenters::Groups::GroupIndex.new(obj)
        when ApiClient
          Presenters::ApiClients::ApiClientIndex.new(obj)
        else
          fail 'Unknown type?' + obj.to_s
        end
      end
    end
  end
end
