module Presenters
  module MetaData

    class MetaDataEdit < Presenters::MetaData::ResourceMetaData

      def meta_datum_by_meta_key_id
        @meta_datum_by_meta_key_id ||=
          Hash[
            fetch_relevant_meta_data.map do |meta_datum|
              [
                meta_datum.meta_key_id,
                Presenters::MetaData::MetaDatumEdit.new(meta_datum, @user)
              ]
            end
          ]
      end

      def existing_meta_data_by_meta_key_id
        @existing_meta_data_by_meta_key_id ||=
          begin
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
      end

      private

      def relevant_meta_keys
        @relevant_meta_keys ||=
          begin
            parent_resource_type = @app_resource.class.name.underscore
            MetaKey
              .where("is_enabled_for_#{parent_resource_type.pluralize}" => true)
              .joins(:vocabulary)
              .where(vocabularies: { id: relevant_vocabularies.map(&:id) })
          end
      end

      def fetch_relevant_meta_data
        @fetch_relevant_meta_data ||=
          begin
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
                  md_klass.new(
                    meta_key: key,
                    parent_resource_type => @app_resource)
                end
              end
          end
      end

      def presenterify_vocabulary_and_meta_data(bundle, _presenter = nil)
        super(bundle, Presenters::MetaData::MetaDatumEdit)
      end

    end
  end
end
