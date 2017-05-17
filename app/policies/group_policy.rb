class GroupPolicy < DefaultPolicy

  def show?
    logged_in? and group_member?
  end

  def new?
    logged_in?
  end

  def edit? # only internal groups can be edited at all
    logged_in? and group_member? and internal_group?
  end

  alias_method :update?, :edit?
  alias_method :update_and_manage_members?, :edit?

  def destroy? # Groups can only be deleted by last remaining member
    logged_in? and record.users == [user]
  end

  private

  def internal_group?
    record.type.to_sym == :Group
  end

  def group_member?
    record.users.exists?(id: user.id)
  end

end
