module Presenters
  module Batch
    class BatchAddToSet < Presenter

      attr_accessor :resource_ids
      attr_accessor :search_term
      attr_accessor :return_to

      def initialize(initial_values)
        @user = initial_values[:user]
        @resource_ids = initial_values[:resource_ids]
        @search_results = []
        @search_term = initial_values[:search_term]
        @return_to = initial_values[:return_to]
      end

      def search_results
        @search_results = {
          collections: [],
          has_more: false
        }
        if @search_term.presence
          @search_results = search_collections(@user, @search_term)
        end
        @search_results
      end

      def batch_count
        @resource_ids.length
      end

      def batch_select_add_to_set_url
        batch_select_add_to_set_path
      end

      def batch_add_to_set_url
        batch_add_to_set_path
      end

      private

      def search_collections(user, search_term)
        # Find all where the title contains the search term
        # anywhere (case insensitive), but prefere the titles (trimmed)
        # which start with the search term

        rank_query = <<-SQL
          case when position(
            lower(
              '%s'
            ) in lower(
              trim(both ' ' from meta_data.string))
            ) = 1 then '1' else '2' end as rank
        SQL

        rank_query_with_search_term = ActiveRecord::Base.send(
          :sanitize_sql_array,
          [
            rank_query,
            search_term
          ]
        )

        result = Collection.editable_by_user(user)
          .select('collections.*')
          .select(rank_query_with_search_term)
          .joins(:meta_data)
          .where(meta_data: { meta_key_id: 'madek_core:title' })
          .where('meta_data.string ILIKE :term', term: "%#{search_term}%")
          .reorder('rank ASC, meta_data.string ASC')
          .limit(11)

        {
          collections: result.slice(0, 10).map do |collection|
            Presenters::Collections::CollectionIndex.new(
              collection, @user
            )
          end,
          has_more: result.length == 11
        }
      end
    end
  end
end
