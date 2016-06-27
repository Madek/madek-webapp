module Presenters
  module Batch
    class BatchAddToSet < Presenter

      attr_accessor :media_entry_ids
      attr_accessor :search_term
      attr_accessor :return_to

      def initialize(user, media_entry_ids, resources, search_term, return_to)
        @user = user
        @media_entry_ids = media_entry_ids
        @resources = resources
        @search_results = []
        @search_term = search_term
        @return_to = return_to
      end

      def search_results
        @search_results = []
        if @search_term.presence
          @search_results = search_collections(@user, @search_term)
            .map do |collection|
              Presenters::Collections::CollectionIndex.new(
                collection, @user
              )
            end
        end
        @search_results
      end

      def batch_count
        @media_entry_ids.length
      end

      def batch_select_add_to_set_url
        batch_select_add_to_set_path
      end

      def batch_add_to_set_url
        batch_add_to_set_path
      end

      private

      def search_collections(user, search_term)
        result = Collection.editable_by_user(user)
          .joins(:meta_data)
          .where(meta_data: { meta_key_id: 'madek_core:title' })
          .where('meta_data.string ILIKE :term', term: "%#{search_term}%")
          .reorder('meta_data.string ASC')

        if result.length > 10
          result = result.slice(0, 10)
        end
        result
      end

    end
  end
end
