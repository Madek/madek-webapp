module WorkflowLocker
  module Validation
    class ValidationError < StandardError; end

    private

    def required_context_keys(resource)
      if resource.is_a?(Collection)
        [
          meta_key_id: 'madek_core:title'
        ]
      else
        @required_context_keys ||= (
          app_settings = AppSetting.first
          context = app_settings.contexts_for_entry_validation.first
          context.context_keys.where(is_required: true)
        )
      end
    end

    def error_message(context_key)
      Presenters::ContextKeys::ContextKeyCommon.new(context_key).label +
        ' is missing'
    end

    def validate_and_publish!
      nested_resources.each do |nested_resource|
        resource = nested_resource.cast_to_type.reload
        has_errors = false
        required_context_keys(resource).each do |rck|
          next if resource.meta_data.find_by(meta_key_id: rck.meta_key_id)

          has_errors = true
          @errors[resource.title] ||= []
          @errors[resource.title] << error_message(rck)
        end

        if resource.is_a?(MediaEntry) && !has_errors
          resource.update!(is_published: true)
        end
      end

      unless @errors.blank?
        raise ValidationError
      end
    end
  end
end
