module Presenters
  module MediaEntries
    class MediaEntrySelectCollection < Presenter

      attr_reader :search_term
      attr_reader :collection_rows
      attr_reader :reduced_set

      def initialize(user, media_entry, search_term)
        @user = user
        @media_entry = media_entry
        @search_term = search_term
        @reduced_set = false
        @length = 30

        collections = if search_term.presence
                        search_collections(user)
                      else
                        marked_collections(media_entry)
                      end

        @collection_rows = collections.map do |collection|
          contains_media_entry = media_entry
            .parent_collections.include?(collection)

          {
            contains_media_entry: contains_media_entry,
            collection: Presenters::Collections::CollectionIndex.new(
              collection, @user)
          }
        end
      end

      def title
        @media_entry.title
      end

      def add_to_collection_url
        add_to_collection_media_entry_path(@media_entry)
      end

      def select_collection_url
        select_collection_media_entry_path(@media_entry)
      end

      def media_entry_url
        media_entry_path(@media_entry)
      end

      private

      def search_collections(user)
        result = Collection.editable_by_user(user)
          .joins('LEFT JOIN meta_data ON meta_data.collection_id = collections.id')
          .where(meta_data: { type: 'MetaDatum::Text' })
          .where('string ILIKE :term', term: "%#{@search_term}%")
          .reorder('meta_data.string ASC')

        if result.length > @length
          @reduced_set = true
          result = result.slice(0, @length)
        end
        result
      end

      def marked_collections(media_entry)
        media_entry.parent_collections
          .joins('LEFT JOIN meta_data ON meta_data.collection_id = collections.id')
          .reorder('meta_data.string ASC')
      end
    end
  end
end
