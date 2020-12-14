module Presenters
  module MediaEntries
    class MediaEntrySiblings < Presenters::Shared::AppResourceWithUser
      def siblings
        @app_resource.sibling_media_entries(@user).map do |item|
          item[:collection] = Presenters::Collections::CollectionIndex.new(item[:collection], @user)
          item[:media_entries] = item[:media_entries].map do |me|
            Presenters::MediaEntries::MediaEntryIndex.new(me, @user)
          end
          item
        end
      end
    end
  end
end
