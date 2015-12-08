module Presenters
  module FilterSets
    class FilterSetShow < Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::FilterSets::Modules::FilterSetCommon

      # TODO: select correct resource_type!!!
      def resources
        Presenters::MediaEntries::MediaEntries.new(
          MediaEntry.filter_by(**saved_filter), @user, list_conf: @list_conf)
      end

    end
  end
end
