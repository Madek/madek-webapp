module Presenters
  module MetaData

    class MetaDataEdit < Presenters::MetaData::ResourceMetaData

      def by_context
        nil
      end

      private

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

    end
  end
end
