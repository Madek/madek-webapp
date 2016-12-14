class UserPolicy < DefaultPolicy

  def toggle_uberadmin?
    user.admin?
  end

end
