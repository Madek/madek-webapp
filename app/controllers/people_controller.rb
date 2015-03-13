class PeopleController < ApplicationController

  def show
    @get = \
      Presenters::People::PersonShow.new \
        Person.find(params[:id]),
        current_user
    respond_with_presenter_formats
  end

end
