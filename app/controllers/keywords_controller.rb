class KeywordsController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  private

  def filter_by_search_params(ar_collection, meta_key_id, search_term, used_by_id)
    ar_collection.filter_by(meta_key_id, search_term, used_by_id)
  end

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [meta_key_id_param, params[:search_term], params[:used_by_id]]
  end
end
