module Presenters
  module MetaData
    class MetaDatumCommon < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        super(app_resource)
        @user = user
      end

      delegate_to_app_resource(:meta_key_id,
                               :type,
                               :media_entry_id,
                               :collection_id,
                               :filter_set_id)

      def meta_key
        Presenters::MetaKeys::MetaKeyCommon.new(@app_resource.meta_key)
      end

      def values
        @values ||= wrap_in_array(@app_resource.value)
          .map { |v| indexify_if_necessary(v) }
      end

      def literal_values
        return if @app_resource.is_a?(MetaDatum::JSON) # dont doubly include potentially huge text
        @literal_values ||= values.map { |v| v.is_a?(Presenter) ? v.uuid : v }
      end

      def url
        prepend_url_context meta_datum_path(@app_resource)
      end

      def api_data_stream_url
        # link to "value blob" in API, only relevant for type JSON
        return unless @app_resource.is_a?(MetaDatum::JSON)
        prepend_url_context "/api/meta-data/#{@app_resource.id}/data-stream"
      end

      private

      def wrap_in_array(value)
        if value.class < ActiveRecord::Associations::CollectionProxy
          value
        elsif value.is_a?(PeopleWithRoles)
          value
        else
          [value]
        end
      end

      def indexify_media_entry_if_exists(media_entry)
        if media_entry
          Presenters::MediaEntries::MediaEntryIndex.new(media_entry, @user)
        else
          ''
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def indexify_if_necessary(value)
        case value.class.name
        when 'Person'
          Presenters::People::PersonIndex.new(value)
        when 'User'
          Presenters::Users::UserIndex.new(value)
        when 'Group'
          Presenters::Groups::GroupIndex.new(value)
        when 'InstitutionalGroup'
          Presenters::Groups::GroupIndex.new(value)
        when 'Keyword'
          Presenters::Keywords::KeywordIndex.new(value)
        when 'Role'
          Presenters::Roles::RoleIndex.new(value)
        when 'MetaDatum::Role'
          Presenters::People::PersonIndexForRoles.new(value)
        when 'PersonWithRoles'
          Presenters::People::PersonIndexForRoles.new(value)
        when 'MetaDatum::MediaEntry'
          [
            indexify_media_entry_if_exists(value.other_media_entry),
            value.string.presence || ''
          ]
        else # all other values are "primitive/literal/unspecified":
          value
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
