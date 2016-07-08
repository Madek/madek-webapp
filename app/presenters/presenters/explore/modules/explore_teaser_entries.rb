module Presenters
  module Explore
    module Modules
      module ExploreTeaserEntries

        private

        def teaser_entries_with_presenter(entry_presenter)
          teaser = Collection.find_by_id(@settings.teaser_set_id)
          return [] unless teaser

          authorized_entries = \
            MediaEntryPolicy::Scope.new(@user, teaser.media_entries).resolve
          .limit(12)

          authorized_entries.map { |entry| entry_presenter.new(entry) }
        end

      end
    end
  end
end
