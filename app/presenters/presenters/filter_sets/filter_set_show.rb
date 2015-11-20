module Presenters
  module FilterSets
    class FilterSetShow < Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::FilterSets::Modules::FilterSetCommon

      def media_entries
        Presenters::MediaEntries::MediaEntries.new(
          MediaEntry.filter_by(**saved_filter), @user, list_conf: @list_conf)
      end

      def collections
        Presenters::Collections::Collections.new(
          Collection.filter_by(**saved_filter), @user, list_conf: @list_conf)
      end

      def filter_sets
        Presenters::FilterSets::FilterSets.new(
          FilterSet.filter_by(**saved_filter), @user, list_conf: @list_conf)
      end

    end
  end
end
