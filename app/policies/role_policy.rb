class RolePolicy < DefaultPolicy

  def index?
    logged_in?
  end

end
