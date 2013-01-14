class SearchController < ApplicationController

  respond_to 'html'

  before_filter do
    @a_top_keyword = (view_context.hash_for Keyword.with_count.limit(12)).shuffle.first    
  end

  def search
    if request.post?
      unless params[:search].blank?
        redirect_to :action => 'term', :term => params[:search]
      else
        redirect_to media_resources_path(:filterpanel => "true")
      end
    else
      render "search"
    end
  end

  def term
    @term = params[:term]
    @result_count_for_term = MediaResource.filter(current_user, MediaResource.get_filter_params({:search => @term})).count
  end

end
