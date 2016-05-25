module Presenters
  module MetaData

    class MetaDataEdit < Presenters::MetaData::ResourceMetaData

      def by_context_edit
        contexts = contexts_for_show.map do |context|
          build_meta_data_context_edit(context)
        end
        contexts.select do |context|
          !context.meta_data.empty?
        end
      end

      private

      def build_meta_data_context_edit(context)
        Pojo.new(
          context: Presenters::Contexts::ContextCommon.new(context),
          meta_data: context.context_keys.map do |c_key|
            next unless context_key_usable(c_key)
            md = @app_resource.meta_data.find_by(meta_key: c_key.meta_key)
            unless md.present?
              md = create_empty_meta_datum_for_edit(c_key)
            end
            Presenters::MetaData::MetaDatumEdit.new(md, @user)
          end
          .compact)
      end

      def create_empty_meta_datum_for_edit(context_key)
        parent_resource_type = @app_resource.class.name.underscore
        key = context_key.meta_key
        md_klass = key.meta_datum_object_type.constantize
        md_klass.new(
          meta_key: key,
          parent_resource_type => @app_resource)
      end

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
