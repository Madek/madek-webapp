module Presenters
  module MetaData

    class MetaDataEdit < Presenters::MetaData::ResourceMetaData

      def meta_datum_by_meta_key_id
        Hash[
          fetch_relevant_meta_data.map do |meta_datum|
            [
              meta_datum.meta_key_id,
              Presenters::MetaData::MetaDatumEdit.new(meta_datum, @user)
            ]
          end
        ]
      end

      def mandatory_by_meta_key_id
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

      def relevant_meta_keys
        parent_resource_type = @app_resource.class.name.underscore
        MetaKey
          .where("is_enabled_for_#{parent_resource_type.pluralize}" => true)
          .joins(:vocabulary)
          .where(vocabularies: { id: relevant_vocabularies.map(&:id) })
      end

      def existing_meta_data_by_meta_key_id
        datums = relevant_meta_keys.map do |key|
          @app_resource.meta_data.where(meta_key_id: key.id).first
        end

        datums = datums.select do |hash|
          hash
        end

        Hash[
          datums.map do |meta_datum|
            next unless meta_datum.id
            [
              meta_datum.meta_key_id,
              Presenters::MetaData::MetaDatumCommon.new(meta_datum, @user)
            ]
          end
        ]
      end

      private

      def context_key_usable(context_key)
        parent_resource_type = @app_resource.class.name.underscore
        viewable = context_key.meta_key.vocabulary.viewable_by_user?(@user)
        enabled = context_key.meta_key.send(
          "is_enabled_for_#{parent_resource_type.pluralize}")
        viewable and enabled
      end

      def fetch_relevant_meta_data
        parent_resource_type = @app_resource.class.name.underscore
        MetaKey
          .where("is_enabled_for_#{parent_resource_type.pluralize}" => true)
          .joins(:vocabulary)
          .where(vocabularies: { id: relevant_vocabularies.map(&:id) })
          .map do |key|
            existing_datum = @app_resource.meta_data.where(meta_key: key).first
            if existing_datum.present?
              existing_datum
            else # prepare a new, blank instance to "fill out":
              md_klass = key.meta_datum_object_type.constantize
              md_klass.new(meta_key: key, parent_resource_type => @app_resource)
            end
          end
      end

      def presenterify_vocabulary_and_meta_data(bundle, _presenter = nil)
        super(bundle, Presenters::MetaData::MetaDatumEdit)
      end

    end
  end
end
