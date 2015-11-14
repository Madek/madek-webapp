module Presenters
  module MetaData

    # TODO: real config instead of UI_META_CONFIG[:displayed_vocabularies]

    class MetaDataCommon < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def by_vocabulary
        fetch_relevant_meta_data
          .group_by(&:vocabulary) # for making sure all selected keys are present:
          .reverse_merge(selected_vocabularies.map { |v| [v, nil] }.to_h)
          .map(&method(:presenterify_vocabulary_and_meta_data))
          .sort_by(&method(:index_like_selected_vocabs)).to_h
      end

      private

      # This method fetches the relevant meta_data, to be overriden per action:
      def fetch_relevant_meta_data
        fail '#fetch_relevant_meta_data missing from Presenter: ' + self.class.name
      end

      def relevant_vocabularies
        Vocabulary
          .where(id: selected_vocabularies)
          .viewable_by_user_or_public(@user)
      end

      def selected_vocabularies
        ([Madek::Constants::Webapp::UI_META_CONFIG[:summary_vocabulary]] +
          Madek::Constants::Webapp::UI_META_CONFIG[:displayed_vocabularies])
          .map(&:to_sym).map { |id| Vocabulary.find_by(id: id) }.compact
      end

      def index_like_selected_vocabs(bundle)
        selected_vocabularies.map(&:id).map(&:to_sym).index(bundle[0])
      end

      def presenterify_vocabulary_and_meta_data(bundle)
        vocabulary, meta_data = bundle
        meta_data = \
          if meta_data.nil? then []
          else meta_data
            .sort_by { |md| md.meta_key.position }
            .map { |md| Presenters::MetaData::MetaDatumCommon.new(md, @user) }
          end

        [vocabulary.id.to_sym, Pojo.new(
          vocabulary: Presenters::Vocabularies::VocabularyCommon.new(vocabulary),
          meta_data: meta_data)
        ]
      end

    end
  end
end
