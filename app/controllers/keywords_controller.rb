class KeywordsController < ApplicationController
  include Concerns::JSONSearch
  include Concerns::KeywordTermRoutingHelper
  include Modules::Keywords::SortByMatchRelevance

  def index
    get = prepare_array_of_presenter_dumps
    get = sort_by_match_relevance(get) if params[:search_term]
    respond_with get
  end

  def show
    keyword = get_authorized_resource(
      Keyword.find_by!(term: keyword_term_param, meta_key_id: meta_key_id_param))
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
