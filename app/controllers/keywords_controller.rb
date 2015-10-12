class KeywordsController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  private

  def filter_by_search_term(ar_collection, search_term, meta_key_id)
    ar_collection.filter_by(search_term, meta_key_id)
  end

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [params[:search_term], meta_key_id_param]
  end
end
