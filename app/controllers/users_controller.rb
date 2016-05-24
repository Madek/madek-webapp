class UsersController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  private

  def search_params
    [params[:search_term], params[:search_also_in_person]]
  end

end
