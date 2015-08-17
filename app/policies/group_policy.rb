class GroupPolicy < ApplicationPolicy
  def new?
    logged_in?
  end

  def edit?
    logged_in? \
      and group_member?
  end

  def destroy?
    logged_in? \
      and record.users == [user]
  end

  def update?
    logged_in? \
      and group_member?
  end

  def manage_members?
    logged_in? \
      and group_member? \
      and internal_group?
  end

  alias_method :add_member?, :manage_members?
  alias_method :remove_member?, :manage_members?

  private

  def internal_group?
    record.type.to_sym == :Group
  end

  def group_member?
    record.users.exists?(id: user.id)
  end

  def media_resource
    record.media_entry or
      record.collection or
      record.filter_set
  end
end
