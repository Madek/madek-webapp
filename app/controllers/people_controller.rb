class PeopleController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    person = get_authorized_resource

    respond_with(
      @get = person_show_presenter(person)
    )
  end

  def edit
    person = get_authorized_resource
    auth_authorize person
    @get = Presenters::People::PersonEdit.new(
      person,
      current_user
    )

    respond_with(@get)
  end

  def update
    person = get_authorized_resource
    person.update!(person_params.transform_values(&:presence))

    respond_with(@get = person_show_presenter(person))
  end

  private

  def meta_key_id_param
    params.require(:meta_key_id)
  end

  def search_params
    [meta_key_id_param, params[:search_term]]
  end

  def person_params
    params
      .require(:person)
      .permit(:first_name, :last_name, :pseudonym, :description, external_uris: [])
  end

  def person_show_presenter(person)
    resources_type = params.permit(:type).fetch(:type, nil)

    Presenters::People::PersonShow.new(
      person,
      current_user,
      resources_type,
      resource_list_by_type_param
    )
  end
end
