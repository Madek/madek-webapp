class KeywordsController < ApplicationController
  include Concerns::JSONSearch
  include Concerns::KeywordTermRoutingHelper
  include Modules::Keywords::SortByMatchRelevance

  def index
    get = prepare_array_of_presenter_dumps
    get = sort_by_match_relevance(get) if params[:search_term]
    respond_with get
  end

  def redirect_by_term
    # NOTE: only need to authorize the vocab, no more granualar permissions!
    vocabulary = Vocabulary.find(meta_key_id_param.try(:split, ':').try(:first))
    auth_authorize(vocabulary)
    keyword = Keyword.find_by!(
      term: keyword_term_param(action: 'terms'), meta_key_id: meta_key_id_param)

    redirect_to vocabulary_meta_key_term_show_path(keyword.id)
  end

  def show
    keyword = get_authorized_resource

    contents_path = filtered_index_path(
      meta_data: [{
        key: keyword.meta_key_id, value: keyword.id, type: 'MetaDatum::Keywords'
      }])

    resources_type = params.permit(:type).fetch(:type, nil)

    respond_with(
      @get = Presenters::Vocabularies::VocabularyTerm.new(
        keyword.meta_key.vocabulary,
        keyword,
        contents_path,
        current_user,
        resources_type,
        resource_list_by_type_param,
        { context_key_id: params[:context_key_id], search_term: params[:search_term] })
    )
  rescue ActiveRecord::RecordNotFound
    try_redirect_to_subsequent_resource { |resource| vocabulary_meta_key_term_show_path(resource) }
  end

  private

  def id_param
    params[:keyword_id]
  end

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [meta_key_id_param, params[:search_term], params[:used_by_id]]
  end
end
