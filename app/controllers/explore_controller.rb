class ExploreController < ApplicationController
  include Concerns::MediaResources::CrudActions

  def explore
    respond_with(
      @get = Pojo.new(
        media_entries: presenterify(
          MediaEntry.all, Presenters::MediaEntries::MediaEntries),
        collections: presenterify(
          Collection.all, Presenters::Collections::Collections),
        filter_sets: presenterify(
          FilterSet.all, Presenters::FilterSets::FilterSets)))
  end

end
