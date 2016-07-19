module Presenters
  module MetaData
    class ResourceMetaData < Presenters::Shared::AppResource
      include Presenters::Shared::Modules::VocabularyConfig

      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def summary_context
        @summary_context ||=
          _summary_context.map do |context|
            build_meta_data_context(context)
          end.first
      end

      def contexts_for_show_extra
        @contexts_for_show_extra ||=
          _contexts_for_show_extra.map do |context|
            build_meta_data_context(context)
          end
      end

      private

      def _by_vocabulary(meta_data)
        meta_data
          .group_by(&:vocabulary)
          .sort_by { |v, d| v.id }
          .map(&method(:presenterify_vocabulary_and_meta_data))
      end

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

      def presenterify_vocabulary_and_meta_data(bundle, presenter = nil)
        vocabulary, meta_data = bundle
        presenter ||= Presenters::MetaData::MetaDatumCommon
        meta_data = \
          if meta_data.nil? then []
          else meta_data
            .sort_by { |md| md.meta_key.position }
            .map { |md| presenter.new(md, @user) }
          end

        Pojo.new(
          vocabulary: Presenters::Vocabularies::VocabularyCommon.new(vocabulary),
          meta_data: meta_data)
      end

    end
  end
end
