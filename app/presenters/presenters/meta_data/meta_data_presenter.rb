module Presenters
  module MetaData

    # TODO: cleanup to use MetaDatumPresenter!

    class MetaDataPresenter < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
        @meta_data = list_meta_data
      end

      # def all # not needed atm
      #   @meta_data
      # end

      def by_vocabulary
        @meta_data
          .group_by { |md| md.meta_key.vocabulary.uuid.to_sym }
          .map do |voc_id, dat|
            vocabulary = dat.first.meta_key.vocabulary
            [voc_id, Pojo.new(vocabulary: vocabulary, meta_data: dat)]
          end.to_h
      end

      def vocabularies_with_meta_data
        by_vocabulary.to_h.keys # => [:madek_core, :zhdk, …]
      end

      private

      def list_meta_data
        @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: \
                  { id: Vocabulary.viewable_by_user_or_public(@user) })
          .map { |md| Presenters::MetaData::MetaDatumCommon.new(md, @user) }
      end

    end
  end
end
