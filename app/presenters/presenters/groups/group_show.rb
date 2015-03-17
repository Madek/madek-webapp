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
          @user,
          media_entries: MediaEntry.entrusted_to_group(@app_resource),
          collections: Collection.entrusted_to_group(@app_resource),
          filter_sets: FilterSet.entrusted_to_group(@app_resource)
      end
    end
  end
end
