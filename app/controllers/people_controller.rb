class PeopleController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    person = get_authorized_resource
    resources_type = params.permit(:type).fetch(:type, nil)

    respond_with(
      @get = Presenters::People::PersonShow.new(
        person,
        current_user,
        resources_type,
        resource_list_by_type_param
      )
    )
  end

  private

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [meta_key_id_param, params[:search_term]]
  end

end
