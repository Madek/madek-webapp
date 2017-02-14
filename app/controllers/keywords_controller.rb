class KeywordsController < ApplicationController
  include Concerns::JSONSearch
  include Modules::Keywords::SortByMatchRelevance

  def index
    get = prepare_array_of_presenter_dumps
    get = sort_by_match_relevance(get) if params[:search_term]
    respond_with get
  end

  def show
    # NOTE: Rails' routing normalizes paths, which may include the term,
    # e.g. double slashes in terms are lost in `params.require(:term)`!
    term = CGI.unescape(
      request.original_fullpath.sub("/vocabulary/#{meta_key_id_param}/terms/", ''))

    keyword = get_authorized_resource(
      Keyword.find_by!(term: term, meta_key_id: meta_key_id_param))
    redirect_to_filtered_index(
      meta_data: [{
        key: keyword.meta_key_id,
        value: keyword.id,
        type: 'MetaDatum::Keywords' }])
  end

  private

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [meta_key_id_param, params[:search_term], params[:used_by_id]]
  end
end
