module Presenters
  module MetaData
    class ResourceMetaData < Presenters::Shared::AppResource
      include Presenters::Shared::Modules::VocabularyConfig

      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      # "by Contexts": as configured for display (could be *incomplete*)
      def by_context
        contexts_for_show.map do |context|
          build_meta_data_context(context)
        end
      end

      # *All* metadata, grouped by Vocabulary
      def by_vocabulary
        fetch_relevant_meta_data
          .group_by(&:vocabulary)
          .sort_by { |v, d| v.id }
          .map(&method(:presenterify_vocabulary_and_meta_data))
          .to_h
      end

      private

      def build_meta_data_context(context)
        # NOTE: cant just `JOIN` them all together like in `by_vocabulary`,
        #   because there we can sort later by vocab/key (which have 1:1 relation).
        #   Here we need to do Context -> c_key -> MK -> MD because all are needed.
        Pojo.new(
          context: Presenters::Contexts::ContextCommon.new(context),
          meta_data: context.context_keys.map do |c_key|
            next unless c_key.meta_key.vocabulary.viewable_by_user?(@user)
            md = @app_resource.meta_data.find_by(meta_key: c_key.meta_key)
            next unless md
            Pojo.new(
              context_key: Presenters::ContextKeys::ContextKeyCommon.new(c_key),
              meta_datum: Presenters::MetaData::MetaDatumCommon.new(md, @user))
          end
          .compact)
      end

      # This method fetches the relevant meta_data, to be overriden per action:
      def fetch_relevant_meta_data
        fail '#fetch_relevant_meta_data missing from Presenter: ' + self.class.name
      end

      def relevant_vocabularies
        visible_vocabularies(@user)
      end

      def presenterify_vocabulary_and_meta_data(bundle, presenter = nil)
        vocabulary, meta_data = bundle
        presenter ||= Presenters::MetaData::MetaDatumCommon
        meta_data = \
          if meta_data.nil? then []
          else meta_data
            .sort_by { |md| md.meta_key.position }
            .map { |md| presenter.new(md, @user) }
          end

        [vocabulary.id.to_sym, Pojo.new(
          vocabulary: Presenters::Vocabularies::VocabularyCommon.new(vocabulary),
          meta_data: meta_data)
        ]
      end

    end
  end
end
