module Presenters
  module MetaData
    class MetaMetaDataEdit < Presenter

      include AuthorizationSetup
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
                context: AppSetting.first.contexts_for_entry_validation,
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
        configured_contexts.map &:id
      end

      def vocabularies_by_vocabulary_id
        vocabularies_for_resource_type.map do |vocabulary|
          [
            vocabulary.id,
            Presenters::Vocabularies::VocabularyCommon.new(vocabulary)
          ]
        end.to_h
      end

      def meta_key_ids_by_vocabulary_id
        vocabularies_for_resource_type.map do |vocabulary|
          [
            vocabulary.id,
            vocabulary.meta_keys.map(&:id)
          ]
        end.to_h
      end

      def contexts_by_context_id
        @contexts_by_context_id ||=
          Hash[
            configured_contexts.map do |context|
              [context.id, Presenters::Contexts::ContextCommon.new(context)]
            end
          ]
      end

      def meta_key_by_meta_key_id
        @meta_key_by_meta_key_id ||=
          Hash[
            relevant_meta_keys.map do |key|
              [key.id, Presenters::MetaKeys::MetaKeyEdit.new(key)]
            end
          ]
      end

      def meta_key_id_by_context_key_id
        @meta_key_id_by_context_key_id ||=
          Hash[
            configured_contexts.flat_map do |context|
              context.context_keys.map do |context_key|
                [context_key.id, context_key.meta_key_id]
              end
            end
          ]
      end

      def context_key_by_context_key_id
        @context_key_by_context_key_id ||=
          Hash[
            configured_contexts.flat_map do |context|
              context.context_keys.map do |context_key|
                [
                  context_key.id,
                  Presenters::ContextKeys::ContextKeyCommon.new(context_key)
                ]
              end
            end
          ]
      end

      def context_key_ids_by_context_id
        @context_key_ids_by_context_id ||=
          Hash[
            configured_contexts.map do |context|
              [
                context.id,
                context.context_keys.sort_by(&:position).map do |context_key|
                  next unless context_key_usable(context_key)
                  context_key.id
                end
              ]
            end
          ]
      end

      private

      def vocabularies_for_resource_type
        plural = @resource_class.name.underscore.pluralize
        auth_policy_scope(@user, Vocabulary.all, VocabularyPolicy::UsableScope)
        .joins(:meta_keys)
        .where(
          "meta_keys.is_enabled_for_#{plural}" => true
        ).distinct
      end

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

      def configured_contexts
        # see VocabularyConfig
        case @resource_class.name
        when 'MediaEntry' then _contexts_for_entry_edit
        when 'Collection' then _contexts_for_collection_edit
        else fail 'Invalid resource_class!'
        end
      end
    end
  end
end
