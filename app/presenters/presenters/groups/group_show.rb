module Presenters
  module Groups
    class GroupShow < GroupCommon
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def entrusted_media_resources
        Pojo.new(
          media_entries: \
            Presenters::MediaEntries::MediaEntries \
              .new(@user, MediaEntry.entrusted_to_group(@app_resource)),
          collections: \
            Presenters::Collections::Collections \
              .new(@user, Collection.entrusted_to_group(@app_resource)),
          filter_sets: \
            Presenters::FilterSets::FilterSets \
              .new(@user, FilterSet.entrusted_to_group(@app_resource))
        )
      end
    end
  end
end
