class PeopleController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    person = get_authorized_resource
    redirect_to_filtered_index(
      meta_data: [{ key: 'any', value: person.id, type: 'MetaDatum::People' }])
  end

end
