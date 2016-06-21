module Presenters
  module MetaData

    class MetaMetaDataEdit < Presenter

      include Presenters::Shared::Modules::VocabularyConfig

      def initialize(user, resource_class)
        @user = user
        @resource_class = resource_class
      end

      def mandatory_by_meta_key_id
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

      def context_ids
        contexts_for_show.map &:id
      end

      def contexts_by_context_id
        Hash[
          contexts_for_show.map do |context|
            [context.id, Presenters::Contexts::ContextCommon.new(context)]
          end
        ]
      end

      def meta_key_by_meta_key_id
        Hash[
          relevant_meta_keys.map do |key|
            [key.id, Presenters::MetaKeys::MetaKeyCommon.new(key)]
          end
        ]
      end

      def meta_key_ids_by_context_id
        Hash[
          contexts_for_show.map do |context|
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
        viewable = context_key.meta_key.vocabulary.viewable_by_user?(@user)
        enabled = context_key.meta_key.send(
          "is_enabled_for_#{parent_resource_type.pluralize}")
        viewable and enabled
      end

      def relevant_meta_keys
        parent_resource_type = @resource_class.name.underscore
        MetaKey
          .where("is_enabled_for_#{parent_resource_type.pluralize}" => true)
          .joins(:vocabulary)
          .where(vocabularies: { id: relevant_vocabularies.map(&:id) })
      end

      def relevant_vocabularies
        visible_vocabularies(@user)
      end

    end
  end
end
