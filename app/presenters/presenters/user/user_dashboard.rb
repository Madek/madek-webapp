module Presenters
  module User
    class UserDashboard < Presenter

      def initialize(user, limit)
        @user = user
        @limit = limit
      end

      def my_content
        {
          media_entries:
            @user.media_entries.reorder('created_at DESC').limit(@limit)
              .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me) },
          collections:
            @user.collections.reorder('created_at DESC').limit(@limit)
              .map { |me| Presenters::Collections::CollectionThumb.new(me) },
          filter_sets:
            @user.filter_sets.reorder('created_at DESC').limit(@limit)
              .map { |me| Presenters::FilterSets::FilterSetThumb.new(me) },
          imports:
            @user.created_media_entries.reorder('created_at DESC').limit(@limit)
              .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me) }
        }
      end

      def latest_imports
        @user.created_media_entries.reorder('created_at DESC').limit(@limit)
          .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me) }
      end

      def favorites
        {
          media_entries: @user.favorite_media_entries.limit(@limit),
          collections: @user.favorite_collections.limit(@limit),
          filter_sets: @user.favorite_filter_sets.limit(@limit)
        }
      end

      def entrusted
        {
          media_entries:
            MediaEntry.entrusted_to_user(@user)
              .reorder('created_at DESC').limit(@limit)
              .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me) },
          collections:
            Collection.entrusted_to_user(@user)
              .reorder('created_at DESC').limit(@limit)
              .map { |c| Presenters::Collections::CollectionThumb.new(c) },
          filter_sets:
            FilterSet.entrusted_to_user(@user)
              .reorder('created_at DESC').limit(@limit)
              .map { |fs| Presenters::FilterSets::FilterSetThumb.new(fs) }
        }
      end

      def groups
        @user.groups.limit(4)
      end

    end
  end
end
