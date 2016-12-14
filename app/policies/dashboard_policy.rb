class DashboardPolicy < DefaultPolicy
  attr_reader :user

  def initialize(user, dashboard)
    super(user, dashboard)
    @dashboard = dashboard
  end

  alias_method :logged_in?, :user
end
