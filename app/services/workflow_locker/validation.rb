module WorkflowLocker
  module Validation
    class ValidationError < StandardError; end

    private

    def required_context_keys(resource)
      return @required_context_keys if @required_context_keys
      if resource.is_a?(Collection)
        [meta_key_id: 'madek_core:title']
      else
        @required_context_keys = (
          app_settings = AppSetting.first
          context = app_settings.contexts_for_entry_validation.first
          context&.context_keys&.where(is_required: true)
        ).to_a

        if (workflow = resource.try(:workflow))
          @required_context_keys.concat(
            workflow.mandatory_meta_key_ids.map { |mk| { meta_key_id: mk } }
          )
        end
      end
    end

    def error_message(meta_key)
      Presenters::MetaKeys::MetaKeyCommon.new(meta_key).label + ' is missing'
    end

    def validate_and_publish!
      nested_resources.each do |nested_resource|
        resource = nested_resource.cast_to_type.reload
        has_errors = false
        required_context_keys(resource).each do |rck|
          next if resource.meta_data.find_by(meta_key_id: rck[:meta_key_id])
          meta_key = MetaKey.find(rck[:meta_key_id]) rescue next

          has_errors = true
          @errors[resource.title] ||= []
          @errors[resource.title] << error_message(meta_key)
        end

        resource.update!(is_published: true) if resource.is_a?(MediaEntry) && !has_errors
      end

      raise ValidationError unless @errors.blank?
    end
  end
end
