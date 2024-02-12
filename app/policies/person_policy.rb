class PersonPolicy < DefaultPolicy

  def index?
    logged_in?
  end

  def update?
    logged_in? and @user.person_id == @record.id
  end

end
