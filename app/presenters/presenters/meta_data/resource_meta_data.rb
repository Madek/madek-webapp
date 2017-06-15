module Presenters
  module MetaData
    class ResourceMetaData < Presenters::Shared::AppResource
      include Presenters::Shared::Modules::VocabularyConfig
      include Presenters::Shared::Modules::MetaDataPerContexts

      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def entry_summary_context
        @entry_summary_context ||=
          _entry_summary_context.map do |context|
            _build_meta_data_context(context)
          end.first
      end

      def collection_summary_context
        @collection_summary_context ||=
          _collection_summary_context.map do |context|
            _build_meta_data_context(context)
          end.first
      end

      def contexts_for_entry_extra
        @contexts_for_entry_extra ||=
          _contexts_for_entry_extra.map do |context|
            _build_meta_data_context(context)
          end
      end

      def contexts_for_list_details
        @contexts_for_list_details ||=
          _contexts_for_list_details.map do |context|
            _build_meta_data_context(context)
          end
      end

      private

      def _build_meta_data_context(context)
        build_meta_data_context(@app_resource, @user, context)
      end

      def _by_vocabulary(meta_data)
        meta_data
          .group_by(&:vocabulary)
          .sort_by { |v, d| v.position }
          .map(&method(:presenterify_vocabulary_and_meta_data))
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
