class SearchController < ApplicationController

  respond_to 'html'

  before_filter do
    @a_top_keyword = (view_context.hash_for Keyword.with_count_for_accessible_media_resources(current_user).limit(25)).shuffle.first
  end

  before_filter do 
    params[:term] =  Rack::Utils.unescape(params[:term]) if params[:term]
  end

  def result
    if (@terms = params[:terms]).blank?
      redirect_to media_resources_path(:filterpanel => "true")
    else
      @result_count_for_term = MediaResource \
        .filter(current_user, MediaResource.get_filter_params({:search => @terms})) \
        .count
    end
  end

end
