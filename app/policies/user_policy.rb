class UserPolicy < DefaultPolicy

  def toggle_uberadmin?
    user.admin?
  end

  def set_list_config?
    logged_in?
  end

end
