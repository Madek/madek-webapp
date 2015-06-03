class DashboardPolicy
  attr_reader :user

  def initialize(user, dashboard)
    @user = user
    @dashboard = dashboard
  end

  alias_method :logged_in?, :user
end
