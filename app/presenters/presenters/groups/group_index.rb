module Presenters
  module Groups
    class GroupIndex < GroupCommon

      def entrusted_media_resources_count
        return unless @user
        MediaEntry.entrusted_to_group(@app_resource).count +
          Collection.entrusted_to_group(@app_resource).count +
            FilterSet.entrusted_to_group(@app_resource).count
      end

    end
  end
end
