class WorkflowPolicy < DefaultPolicy
  def index?
    member_of_beta_tester_group?
  end

  def create?
    member_of_beta_tester_group?
  end

  def edit?
    creator? || owner?
  end

  def update?
    edit? && record.is_active
  end

  def update_owners?
    creator? && record.is_active
  end

  alias_method :add_resource?, :update?
  alias_method :save_and_not_finish?, :update?
  alias_method :finish?, :update?
  alias_method :preview?, :update?

  private

  def creator?
    record.creator_id == user.id
  end

  def owner?
    record.owners.exists?(id: user.id)
  end

  def member_of_beta_tester_group?
    user.groups.exists?('e12e1bc0-b29f-5e93-85d6-ff0aae9a9db0')
  end
end
