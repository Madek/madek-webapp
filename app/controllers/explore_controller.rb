class ExploreController < ApplicationController

  def index
    @get = Pojo.new \
      media_entries: presenterify(policy_scope(MediaEntry),
                                  Presenters::MediaEntries::MediaEntries),
      collections: presenterify(policy_scope(Collection),
                                Presenters::Collections::Collections),
      filter_sets: presenterify(policy_scope(FilterSet),
                                Presenters::FilterSets::FilterSets)

    respond_with @get
  end

end
