module Presenters
  module Groups
    class GroupIndex < GroupCommon

      def initialize(app_resource, *user)
        @user = user if user # NOTE: user is optional
        super(app_resource)
      end

      def entrusted_media_resources_count # NOTE: here, `user` is NOT optional…
        throw 'Presenter: GroupIndex: no count without `user`' unless @user
        MediaEntry.entrusted_to_group(@app_resource).count \
        + Collection.entrusted_to_group(@app_resource).count \
        + FilterSet.entrusted_to_group(@app_resource).count
      end

    end
  end
end
