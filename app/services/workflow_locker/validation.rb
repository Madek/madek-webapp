module WorkflowLocker
  module Validation
    class ValidationError < StandardError; end

    private

    def required_meta_key_ids_for(resource)
      case resource
      when Collection
        ['madek_core:title']
      when MediaEntry
        required_meta_key_ids_for_media_entry
      else
        raise "Resource of #{resource.class} class not supported!"
      end
    end

    def required_meta_key_ids_for_media_entry
      return @_required_meta_key_ids_for_media_entry if @_required_meta_key_ids_for_media_entry
      @_required_meta_key_ids_for_media_entry =
        ContextKey.where(
          context: AppSetting.first.contexts_for_entry_validation,
          is_required: true
        ).pluck(:meta_key_id)

      @_required_meta_key_ids_for_media_entry.concat(@workflow.mandatory_meta_key_ids)
      @_required_meta_key_ids_for_media_entry = @_required_meta_key_ids_for_media_entry.uniq
    end

    def error_message(meta_key)
      Presenters::MetaKeys::MetaKeyCommon.new(meta_key).label + ' is missing'
    end

    def validate_and_publish!
      nested_resources.each do |nested_resource|
        resource = nested_resource.cast_to_type.reload
        has_errors = false
        required_meta_key_ids_for(resource).each do |meta_key_id|
          next if resource.meta_data.find_by(meta_key_id: meta_key_id)
          meta_key = MetaKey.find(meta_key_id) rescue next

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
