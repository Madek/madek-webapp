class DelegationPolicy < DefaultPolicy

  def index?
    logged_in?
  end

end
