module Presenters
  module Groups
    class GroupShow < Presenters::Shared::AppResource
      [:name, :institutional?, :institutional_group_name] \
        .each { |m| delegate m, to: :@app_resource }

      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def entrusted_media_resources
        Presenters::Shared::MediaResources::MediaResources.new \
          media_entries:
            MediaEntry.entrusted_to_group(@app_resource)
              .map { |r| MediaEntries::MediaEntryIndex.new(r, @user) },
          collections:
            Collection.entrusted_to_group(@app_resource)
              .map { |r| Collections::CollectionIndex.new(r, @user) },
          filter_sets:
            FilterSet.entrusted_to_group(@app_resource)
              .map { |r| FilterSets::FilterSetIndex.new(r, @user) }
      end

    end
  end
end
