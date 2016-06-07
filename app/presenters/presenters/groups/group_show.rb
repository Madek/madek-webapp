module Presenters
  module Groups
    class GroupShow < GroupCommon

      def entrusted_media_resources
        Pojo.new(
          media_entries: presentify(MediaEntry.entrusted_to_group(@app_resource)),
          collections: presentify(Collection.entrusted_to_group(@app_resource)),
          filter_sets: presentify(FilterSet.entrusted_to_group(@app_resource))
        )
      end

      private

      def presentify(resources)
        Presenters::Shared::MediaResource::MediaResources
          .new(resources, @user, list_conf: @list_conf)
      end
    end
  end
end
