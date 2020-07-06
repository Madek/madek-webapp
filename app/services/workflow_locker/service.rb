module WorkflowLocker
  class Service
    include Validation
    include CommonPermissions
    include CommonMetaData
    include MetaData

    def initialize(object_or_id, meta_data = {})
      @workflow = if object_or_id.is_a?(ApplicationRecord)
        object_or_id
      else
        Workflow.find(object_or_id)
      end
      @meta_data = meta_data
      @errors = {}
    end

    def call
      return false unless @workflow.is_active

      apply_meta_data
      ActiveRecord::Base.transaction do
        @workflow.update!(is_active: false)
        apply_common_permissions
        apply_common_meta_data
        validate_and_publish!
      end

      true
    rescue ValidationError
      @errors
    end

    def save_only
      return false unless @workflow.is_active

      apply_meta_data(allow_blank_values: true)
      true
    rescue ValidationError
      @errors
    end

    private

    def configuration
      @workflow.configuration
    end

    def nested_resources
      @workflow
        .master_collection
        .child_media_resources(media_entries_scope: :descendent_media_entries)
    end
  end
end
