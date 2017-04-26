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
    # NOTE: only need to authorize the vocab, no more granualar permissions!
    vocabulary = Vocabulary.find(meta_key_id_param.try(:split, ':').try(:first))
    auth_authorize(vocabulary)
    keyword = Keyword.find_by!(
      term: keyword_term_param(action: 'terms'), meta_key_id: meta_key_id_param)

    contents_path = filtered_index_path(
      meta_data: [{
        key: keyword.meta_key_id, value: keyword.id, type: 'MetaDatum::Keywords'
      }])

    respond_with(@get = Presenters::Vocabularies::VocabularyTerm.new(
      vocabulary, keyword, contents_path, current_user))
  end

  private

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [meta_key_id_param, params[:search_term], params[:used_by_id]]
  end
end
