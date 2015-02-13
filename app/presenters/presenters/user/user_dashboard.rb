module Presenters
  module User
    class UserDashboard < Presenter

      def initialize(user, limit)
        @user = user
        @limit = limit
      end

      def my_content
        # TODO: PolyRePresent
        {
          media_entries:
            @user.media_entries.reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          collections:
            @user.collections.reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          filter_sets:
            @user.filter_sets.reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) }
        }
      end

      def latest_imports
        @user.created_media_entries.reorder('created_at DESC').limit(@limit)
          .map { |r| thumbify(r) }
      end

      def favorites
        # TODO: PolyRePresent
        {
          media_entries:
            @user.favorite_media_entries.limit(@limit)
              .map { |r| thumbify(r) },
          collections:
            @user.favorite_collections.limit(@limit)
              .map { |r| thumbify(r) },
          filter_sets:
            @user.favorite_filter_sets.limit(@limit)
              .map { |r| thumbify(r) }
        }
      end

      def entrusted
        # TODO: PolyRePresent
        {
          media_entries:
            MediaEntry.entrusted_to_user(@user)
              .reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          collections:
            Collection.entrusted_to_user(@user)
              .reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) },
          filter_sets:
            FilterSet.entrusted_to_user(@user)
              .reorder('created_at DESC').limit(@limit)
              .map { |r| thumbify(r) }
        }
      end

      def groups
        # TODO: GroupsPresenter?
        @user.groups.limit(4).map do |group|
          {
            id: group.id,
            name: group.name
          }
        end
      end

      private

      def thumbify(resource)
        presenter = \
          case resource.class.name
          when 'MediaEntry'
            Presenters::MediaEntries::MediaEntryThumb
          # quick fix:
          when 'MediaEntryIncomplete'
            Presenters::MediaEntries::MediaEntryThumb
          when 'Collection'
            Presenters::Collections::CollectionThumb
          when 'FilterSet'
            Presenters::FilterSets::FilterSetThumb
          else
            raise "Missing presenter: #{resource.class.name}"
          end

        presenter.new(resource, @user)
      end

    end
  end
end
