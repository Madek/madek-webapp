class SearchController < ApplicationController

  # search form
  def show
    skip_authorization
    # render plain: 'index'
  end

  # search result - redirects to filtered index
  def result
    skip_authorization
    string = params.require(:search)
    redirect_to(
      media_entries_path(
        list: { show_filter: true, filter: JSON.generate(search: string) }))
  end

end
