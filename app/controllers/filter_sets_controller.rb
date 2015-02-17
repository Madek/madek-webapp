class FilterSetsController < ApplicationController

  include Concerns::Filters

  def index
    @filter_sets = \
      filter_by_entrusted \
        filter_by_favorite \
          filter_by_responsible \
            FilterSet.all
  end

  def show
    @filter_set = FilterSet.find(params[:id])
  end
end
