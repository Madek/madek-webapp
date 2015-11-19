class AdminPolicy < DefaultPolicy
  def initialize(user, admin)
    @user = user
    @admin = admin
  end

  def logged_in_and_admin?
    user and user.admin?
  end
end
