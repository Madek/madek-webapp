module Presenters
  module Users
    class UserDashboard < Presenters::Shared::AppResource

      def initialize(user, limit)
        super(user)
        @limit = limit
      end

      def my_content
        Presenters::Shared::MediaResources::MediaResources.new \
          media_entries:
            @app_resource.media_entries.reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          collections:
            @app_resource.collections.reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          filter_sets:
            @app_resource.filter_sets.reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) }
      end

      def latest_imports
        Presenters::Shared::MediaResources::MediaResources.new \
          media_entries:
            @app_resource
              .created_media_entries
              .reorder('created_at DESC')
              .limit(@limit)
              .map { |r| thumbify(r) }
      end

      def favorites
        Presenters::Shared::MediaResources::MediaResources.new \
          media_entries:
            @app_resource.favorite_media_entries.limit(@limit)
              .map { |r| thumbify(r) },
          collections:
            @app_resource.favorite_collections.limit(@limit)
              .map { |r| thumbify(r) },
          filter_sets:
            @app_resource.favorite_filter_sets.limit(@limit)
              .map { |r| thumbify(r) }
      end

      def entrusted
        Presenters::Shared::MediaResources::MediaResources.new \
          media_entries:
            MediaEntry.entrusted_to_user(@app_resource)
              .reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          collections:
            Collection.entrusted_to_user(@app_resource)
              .reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          filter_sets:
            FilterSet.entrusted_to_user(@app_resource)
              .reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) }
      end

      def groups
        # TODO: GroupsPresenter?
        @app_resource.groups.limit(4).map do |group|
          {
            id: group.id,
            name: group.name
          }
        end
      end

      private

      def thumbify(media_resource)
        presenter = \
          case media_resource.class.name
          when 'MediaEntry'
            Presenters::MediaEntries::MediaEntryIndex
          # quick fix:
          when 'MediaEntryIncomplete'
            Presenters::MediaEntries::MediaEntryIndex
          when 'Collection'
            Presenters::Collections::CollectionIndex
          when 'FilterSet'
            Presenters::FilterSets::FilterSetIndex
          else
            raise "Missing presenter: #{media_resource.class.name}"
          end

        presenter.new(media_resource, @app_resource)
      end

    end
  end
end
