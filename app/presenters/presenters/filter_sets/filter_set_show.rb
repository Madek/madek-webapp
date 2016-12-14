module Presenters
  module FilterSets
    class FilterSetShow < Presenters::Shared::AppResource

      include Presenters::FilterSets::Modules::FilterSetCommon
      include Presenters::Shared::MediaResource::Modules::PrivacyStatus

      def initialize(app_resource, user, list_conf:)
        super(app_resource)
        @user = user
        @list_conf = list_conf
      end

      # TODO: MultiMediaResourceBox. Currently only Entries.
      def resources
        Presenters::MediaEntries::MediaEntries.new(
          MediaEntryPolicy::VisibleScope.new(@user, MediaEntry)
            .resolve
            .filter_by(**saved_filter), @user, list_conf: @list_conf)
      end

    end
  end
end
