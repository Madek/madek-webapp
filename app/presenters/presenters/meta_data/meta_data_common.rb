module Presenters
  module MetaData

    # TODO: real config instead of UI_META_CONFIG[:displayed_vocabularies]

    class MetaDataCommon < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
        @meta_data = nil
      end

      def by_vocabulary
        presenterify(@meta_data || fetch_relevant_meta_data)
          .group_by { |md| md.meta_key.vocabulary.uuid.to_sym }
          .map(&method(:wrap_vocabulary_meta_data))
          .sort_by(&method(:vocabularies_index))
          .to_h
      end

      def vocabularies_with_meta_data
        by_vocabulary.to_h.keys # => [:madek_core, :zhdk, …]
      end

      # def list TMP disable (performance of dump)
      #   presenterify list_meta_data
      # end

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
        UI_META_CONFIG[:displayed_vocabularies].map(&:to_sym)
      end

      # keep order same as configured:
      def vocabularies_index(voc_and_meta_data)
        vocabulary_id = voc_and_meta_data.first
        selected_vocabularies.index(vocabulary_id.to_sym)
      end

      def wrap_vocabulary_meta_data(voc_and_meta_data)
        voc_id, meta_data = voc_and_meta_data
        meta_data = meta_data.sort_by { |md| md.meta_key.position }
        vocabulary = meta_data.first.meta_key.vocabulary
        [voc_id, Pojo.new(vocabulary: vocabulary, meta_data: meta_data)]
      end

      def presenterify(meta_data)
        meta_data.map { |md| Presenters::MetaData::MetaDatumCommon.new(md, @user) }
      end

    end
  end
end
