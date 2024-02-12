class RolesController < ApplicationController
  include Concerns::JSONSearch

  def index
    auth_authorize :role
    get_and_respond_with_json
  end

  private 

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [params[:search_term], meta_key_id_param]
  end
end
