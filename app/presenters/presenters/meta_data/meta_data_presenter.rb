module Presenters
  module MetaData

    # TODO: maybe cleanup once the API is 'stable'

    class MetaDataPresenter < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
        @by_vocabulary = by_vocabulary
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

        return @by_vocabulary if @by_vocabulary

        data = @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: \
                  { id: Vocabulary.viewable_by_user_or_public(@user) })
          .map { |md| Presenters::MetaData::MetaDatumCommon.new(md) }
          .map { |md_p| build_key_values_tuple(md_p) }
          .group_by { |tuple| tuple._key.vocabulary_id }

        data = build_vocabulary_tuples(data)
        Pojo.new(data)
      end

      def vocabularies_with_meta_data
        by_vocabulary.to_h.keys # => [:madek_core, :zhdk, …]
      end

      private

      def build_key_values_tuple(md_presenter)
        Pojo.new(Hash[
          '_url', md_presenter.url,
          '_key', md_presenter.meta_key,
          '_values', md_presenter.values
        ])
      end

      def build_vocabulary_tuples(vocabularies)
        vocabularies.each_with_object({}) do |vocab, results|
          vocab_id = vocab[0]
          vocabulary = \
            Presenters::Vocabularies::VocabularyCommon.new \
              Vocabulary.find(vocab_id)
          meta_data = vocab[1]
          results[vocab_id] = Pojo.new(Hash[
            '_vocabulary', vocabulary,
            '_meta_data', meta_data
          ])
        end
      end
    end
  end
end
