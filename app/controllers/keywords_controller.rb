class KeywordsController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    term = params.require(:term)
    keyword = get_authorized_resource(Keyword.find_by!(term: term))
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
