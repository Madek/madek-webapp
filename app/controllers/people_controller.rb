class PeopleController < ApplicationController

  def show
    @get = Presenters::People::PersonShow.new(Person.find(params[:id]))
    respond_with_presenter_formats
  end

end
