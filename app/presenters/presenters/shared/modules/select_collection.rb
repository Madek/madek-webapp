module Presenters
  module Shared
    module Modules
      module SelectCollection

        include Presenters::Shared::Modules::CurrentUser

        attr_reader :search_term
        attr_reader :collection_rows
        attr_reader :reduced_set

        def initialize(user, media_entry, search_term)
          super(media_entry)
          @user = user
          @search_term = search_term
          @reduced_set = false
          @length = 30

          collections = if search_term.presence
            search_collections(user)
          else
            marked_collections(user, media_entry)
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

        def add_remove_collection_url
          raise 'not implemented'
        end

        def select_collection_url
          raise 'not implemented'
        end

        def resource_url
          raise 'not implemented'
        end

        private

        def search_collections(user)
          result = Collection.editable_by_user(user)
            .joins(:meta_data)
            .where(meta_data: { meta_key_id: 'madek_core:title' })
            .where('meta_data.string ILIKE :term', term: "%#{@search_term}%")
            .where(
              'collection_id <> :app_resource_id',
              app_resource_id: @app_resource.id)
            .reorder('meta_data.string ASC')

          if result.length > @length
            @reduced_set = true
            result = result.slice(0, @length)
          end
          result
        end

        def marked_collections(user, media_entry)
          media_entry.parent_collections
            .editable_by_user(user)
            .joins(:meta_data)
            .where(meta_data: { meta_key_id: 'madek_core:title' })
            .reorder('meta_data.string ASC')
        end

      end
    end
  end
end
