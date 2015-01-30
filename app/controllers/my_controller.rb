class MyController < ApplicationController

  LIMIT = 6

  def dashboard
    @get = ::Presenters::User::UserDashboard.new(current_user, LIMIT)
  end

end
