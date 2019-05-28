class WorkflowPolicy < DefaultPolicy
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
end
