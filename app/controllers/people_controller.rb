class PeopleController < ApplicationController
  include Concerns::JSONSearch
  include Concerns::ResourceListParams

  def index
    get_and_respond_with_json
  end

  def show
    respond_with(@get = (Presenters::People::PersonShow.new(
      Person.find(params[:id]), current_user, list_conf: resource_list_params)))
  end

end
