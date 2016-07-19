module Presenters
  module MetaData

    class MetaMetaDataEdit < Presenter

      include Presenters::Shared::Modules::VocabularyConfig

      def initialize(user, resource_class)
        @user = user
        @resource_class = resource_class
      end

      def mandatory_by_meta_key_id
        @mandatory_by_meta_key_id ||=
          begin
            if @resource_class == Collection
              {
                'madek_core:title' => {
                  meta_key_id: 'madek_core:title',
                  context_id: 'hardcoded'
                }
              }
            else
              result = ContextKey.where(
                context: AppSetting.first.contexts_for_validation,
                is_required: true)
              Hash[
                result.map do |context_key|
                  [
                    context_key.meta_key_id,
                    {
                      meta_key_id: context_key.meta_key_id,
                      context_id: context_key.context_id
                    }
                  ]
                end
              ]
            end
        end
      end

      def meta_data_edit_context_ids
        _meta_data_edit_contexts.map &:id
      end

      def context_keys_by_meta_key_id
        @context_keys_by_meta_key_id ||=
          begin
            result = _meta_data_edit_contexts.map do |context|
              Hash[
                context.context_keys.map do |context_key|
                  [
                    context_key.meta_key_id,
                    Presenters::ContextKeys::ContextKeyCommon.new(context_key)
                  ]
                end
              ]
            end
            result.reduce({}, :merge)
          end
      end

      def contexts_by_context_id
        @contexts_by_context_id ||=
          Hash[
            _meta_data_edit_contexts.map do |context|
              [context.id, Presenters::Contexts::ContextCommon.new(context)]
            end
          ]
      end

      def meta_key_by_meta_key_id
        @meta_key_by_meta_key_id ||=
          Hash[
            relevant_meta_keys.map do |key|
              [key.id, Presenters::MetaKeys::MetaKeyCommon.new(key)]
            end
          ]
      end

      def meta_key_ids_by_context_id
        @meta_key_ids_by_context_id ||=
          Hash[
            _meta_data_edit_contexts.map do |context|
              [
                context.id,
                context.context_keys.map do |c_key|
                  next unless context_key_usable(c_key)
                  c_key.meta_key_id
                end
              ]
            end
          ]
      end

      private

      def context_key_usable(context_key)
        parent_resource_type = @resource_class.name.underscore
        viewable = context_key.meta_key.vocabulary.usable_by_user?(@user)
        enabled = context_key.meta_key.send(
          "is_enabled_for_#{parent_resource_type.pluralize}")
        viewable and enabled
      end

      def relevant_meta_keys
        @relevant_meta_keys ||=
          begin
            parent_resource_type = @resource_class.name.underscore
            MetaKey
              .where("is_enabled_for_#{parent_resource_type.pluralize}" => true)
              .joins(:vocabulary)
              .where(vocabularies: { id: usable_vocabularies_for_user.map(&:id) })
          end
      end
    end
  end
end
