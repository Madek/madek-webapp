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
              .new(nil, MediaEntry.entrusted_to_group(@app_resource)),
          collections: \
            Presenters::Collections::Collections \
              .new(nil, Collection.entrusted_to_group(@app_resource)),
          filter_sets: \
            Presenters::FilterSets::FilterSets \
              .new(nil, FilterSet.entrusted_to_group(@app_resource))
        )
      end
    end
  end
end
