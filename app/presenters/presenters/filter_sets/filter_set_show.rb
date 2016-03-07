module Presenters
  module FilterSets
    class FilterSetShow < Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::FilterSets::Modules::FilterSetCommon

      # TODO: MultiMediaResourceBox. Currently only Entries.
      def resources
        Presenters::MediaEntries::MediaEntries.new(
          MediaEntry
            .viewable_by_user_or_public(@user)
            .filter_by(**saved_filter), @user, list_conf: @list_conf)
      end

    end
  end
end
