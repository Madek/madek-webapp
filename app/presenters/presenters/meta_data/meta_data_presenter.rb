module Presenters
  module MetaData

    # TODO: maybe cleanup once the API is 'stable'

    class MetaDataPresenter < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def by_vocabulary
        # - every meta_datum for the @app_resource, that is viewable by @user
        # - as JSON-serializable "tuples" (key/value)
        # - grouped by vocabulary_id
        # example_output = {
        #   "madek_core": {
        #     "_vocabulary": {
        #       "id": "madek_core",
        #       "label": "This is the core madek vocabulary",
        #       "url": "http://example.com/vocabulary/core"
        #     },
        #     "_meta_data": [
        #       {
        #         "_key": {
        #           "id": "madek_core:title",
        #           "label": "bla"
        #         },
        #         "_values": ["My Work"]
        #       },
        #       … more datums …
        #     ]
        #   },
        #   … more vocabularies …
        # }

        data = @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: { id: Vocabulary.viewable_by_user(@user) })
          .group_by(&:meta_key) # merge repeating keys
        data = build_meta_datum_tuples(data)
        data = data.group_by { |tuple| MetaKey.find(tuple._key.id).vocabulary }
        data = build_vocabulary_tuples(data)
        OpenStruct.new(data)
      end

      def vocabularies_with_meta_data
        by_vocabulary.to_h.keys # => [:madek_core, :zhdk, …]
      end

      private

      def build_meta_datum_tuples(data)
        data.map do |meta_datum|
          meta_key = meta_datum[0]
          meta_values = meta_datum[1]
          OpenStruct.new(Hash[
            '_key', OpenStruct.new(
              id: meta_key.id,
              label: meta_key.label,
              type: meta_key.meta_datum_object_type,
              description: meta_key.description,
              position: meta_key.position
            ),
            '_values', ensure_wrapped_in_array(meta_values)
              .map { |value| get_value_according_to_type(value) }
              .flatten
          ])
        end
      end

      def build_vocabulary_tuples(vocabularies)
        vocabularies.each_with_object({}) do |vocab, results|
          vocabulary = vocab[0]
          meta_data = vocab[1]
          results[vocabulary.id] = OpenStruct.new(Hash[
            '_vocabulary', OpenStruct.new(
              id: vocabulary.id,
              label: vocabulary.label,
              description: vocabulary.description
            ),
            '_meta_data', meta_data
          ])
        end
      end

      def get_value_according_to_type(meta_datum)
        case meta_datum.type
        when 'MetaDatum::People'
          meta_datum.people.map \
            { |p| Presenters::People::PersonIndex.new(p) }
        when 'MetaDatum::Users'
          meta_datum.users.map \
            { |u| Presenters::People::PersonIndex.new(u.person) }
        when 'MetaDatum::Groups'
          meta_datum.groups.map \
            { |g| Presenters::Groups::GroupIndex.new(g) }
        when 'MetaDatum::Licenses'
          meta_datum.licenses.map \
            { |l| Presenters::Licenses::LicenseIndex.new(l) }
        when 'MetaDatum::Keywords'
          meta_datum.keywords.map \
            { |k| Presenters::KeywordTerms::KeywordTermIndex.new(k.keyword_term) }
        else # all other values are "primitive/literal/unspecified":
          meta_datum.value
        end
      end

      def ensure_wrapped_in_array(value)
        (value.try(:to_a).is_a?(Array) ? value.to_a : [value]).flatten
      end

    end
  end
end
