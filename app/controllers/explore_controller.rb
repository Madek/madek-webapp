class ExploreController < ApplicationController
  include Concerns::MediaResources::CrudActions

  def index
    respond_with(
      @get = Pojo.new(
        media_entries: presenterify(
          select(MediaEntry), Presenters::MediaEntries::MediaEntries),
        collections: presenterify(
          select(Collection), Presenters::Collections::Collections),
        filter_sets: presenterify(
          select(FilterSet), Presenters::FilterSets::FilterSets)))
  end

  def select(relation)
    resources = relation.viewable_by_user_or_public(current_user)
    authorize(resources)
    resources
  end

end
