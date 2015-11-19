class PeopleController < ApplicationController
  include Concerns::JSONSearch
  include Concerns::ResourceListParams

  def index
    get_and_respond_with_json
  end

  def show
    person = Person.find(params[:id])
    authorize person
    @get = Presenters::People::PersonShow.new(person,
                                              current_user,
                                              list_conf: resource_list_params)
    respond_with @get
  end

end
