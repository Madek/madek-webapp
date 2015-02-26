class MyController < ApplicationController

  LIMIT = 6

  def dashboard
    @get = ::Presenters::Users::UserDashboard.new(current_user, LIMIT)
  end

end
