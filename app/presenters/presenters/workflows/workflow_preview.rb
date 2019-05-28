module Presenters
  module Workflows
    class WorkflowPreview < WorkflowCommon
      attr_reader :fill_data_mode

      def initialize(app_resource, user, fill_data_mode: false)
        super(app_resource, user)
        @fill_data_mode = fill_data_mode
      end

      def child_resources
        arr = [@app_resource.master_collection] +
              @app_resource.master_collection.child_media_resources.to_a
        arr.map do |resource|
          presenterify_resource(resource)
        end
      end

      def actions
        {
          save_and_not_finish: {
            url: save_and_not_finish_my_workflow_path(@app_resource),
            method: 'PATCH'
          },
          finish: {
            url: finish_my_workflow_path(@app_resource),
            method: 'PATCH'
          }
        }.merge(super)
      end

      def common_settings
        { permissions: common_permissions }
      end

      def master_collection
        Presenters::Collections::CollectionIndexWithChildren.new(
          @app_resource.master_collection,
          @user
        )
      end

      private

      def presenterify_resource(resource)
        Presenters::MetaData::EditContextMetaData.new(resource, @user, nil, true)
      end
    end
  end
end
