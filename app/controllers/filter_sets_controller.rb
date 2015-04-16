class FilterSetsController < ApplicationController

  def show
    @filter_set = FilterSet.find(params[:id])
  end

  def permissions_show
    filter_set = FilterSet.find(params[:id])
    @get = \
      ::Presenters::FilterSets::FilterSetPermissionsShow
        .new(filter_set, current_user)
  end
end
