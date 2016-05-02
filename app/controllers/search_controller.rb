class SearchController < ApplicationController

  # search form
  def show
    skip_authorization
    # render plain: 'index'
  end

  # search result - redirects to filtered index
  def result
    skip_authorization
    string_string = params.require(:search)
    redirect_to_filtered_index(search: string_string)
  end

end
