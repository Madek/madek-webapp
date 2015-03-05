class MyController < ApplicationController

  LIMIT = 6

  def dashboard
    @get = ::Presenters::Users::UserDashboard.new(current_user, LIMIT)
    respond_with_presenter_formats
  end

end
