class ApiClientPolicy < DefaultPolicy
  def index?
    logged_in?
  end
end
