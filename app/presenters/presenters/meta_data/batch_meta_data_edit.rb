module Presenters
  module MetaData

    class BatchMetaDataEdit < Presenters::Shared::AppResource

      def initialize(app_resource, user, usable_meta_keys_map)
        super(app_resource)
        @user = user
        @usable_meta_keys_map = usable_meta_keys_map
      end

      def meta_datum_by_meta_key_id
        @meta_datum_by_meta_key_id ||=
          Hash[
            fetch_usable_meta_data.map do |meta_datum|
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
            datums = @usable_meta_keys_map[@app_resource.class.name].map do |key|
              find_meta_datum(key)
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

      def meta_data_list
        @meta_data_list ||= @app_resource.meta_data
      end

      def find_meta_datum(key)
        meta_data_list.select do |e|
          e.meta_key_id == key.id
        end[0]
      end

      def fetch_usable_meta_data
        @fetch_usable_meta_data ||=
          begin
            parent_resource_type = @app_resource.class.name.underscore
            @usable_meta_keys_map[@app_resource.class.name]
              .map do |key|
                existing_datum = find_meta_datum(key)
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

    end
  end
end
