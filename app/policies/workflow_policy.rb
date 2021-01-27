class WorkflowPolicy < DefaultPolicy
  def index?
    beta_tester?
  end

  def create?
    beta_tester?
  end

  def edit?
    beta_tester? && (creator? || owner? || member_of_delegation?)
  end

  def update?
    beta_tester? && (edit? && record.is_active)
  end

  def update_owners?
    beta_tester? && (creator? && record.is_active)
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

  def beta_tester?
    user.groups.exists?(Madek::Constants::BETA_TESTERS_WORKFLOWS_GROUP_ID)
  end

  def member_of_delegation?
    record.delegation_with_user?(user)
  end
end
