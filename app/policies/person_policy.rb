class PersonPolicy < DefaultPolicy
  def update?
    logged_in? and @user.person_id == @record.id
  end
end
