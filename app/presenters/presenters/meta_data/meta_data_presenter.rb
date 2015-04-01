module Presenters
  module MetaData
    class MetaDataPresenter < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def meta_data_by_vocabulary
        vocabularies = Vocabulary.viewable_by_user(@user)
        @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: { id: vocabularies })
          .map do |meta_datum|
            Hash[meta_datum.meta_key_id, Hash['@type', meta_datum.type,
                                              '@value', value(meta_datum)]]
          end
            .group_by { |h| vocabulary_label(h.keys.first) }
      end

      private

      def value(meta_datum)
        wrap_in_array get_value_according_to_type meta_datum
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
        when 'MetaDatum::License'
          Presenters::Licenses::LicenseIndex.new \
            meta_datum.license
        when 'MetaDatum::Keywords'
          meta_datum.keywords.map \
            { |k| Presenters::KeywordTerms::KeywordTermIndex.new(k.keyword_term) }
        else
          # NOTE: for all other literal values
          meta_datum.value
        end
      end

      def wrap_in_array(value)
        value.try(:to_a).is_a?(Array) ? value : [value]
      end

      def vocabulary_label(meta_key_id)
        MetaKey.find(meta_key_id).vocabulary.label
      end
    end
  end
end
