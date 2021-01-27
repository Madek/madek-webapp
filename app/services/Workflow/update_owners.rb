class Workflow::UpdateOwners
  def initialize(workflow, next_owners)
    @workflow = workflow
    @next_owners = next_owners
  end

  def call
    update
  end

  private

  def update
    return if @next_owners.empty?

    Delegation.transaction do
      clear_associations
      @next_owners.each do |delegation_or_user|
        next unless available_types.include?(delegation_or_user['type'])
        klass = delegation_or_user['type'].constantize
        id = delegation_or_user['uuid']
        add_entity(klass.find(id))
      end
    end
  end

  def clear_associations
    @workflow.delegations.clear
    @workflow.owners.clear
  end

  def add_entity(entity)
    case entity
    when Delegation then add_delegation(entity)
    when User then add_user(entity)
    end
  end

  def add_user(user)
    @workflow.owners << user
  end

  def add_delegation(delegation)
    @workflow.delegations << delegation
  end

  def available_types
    ['Delegation', 'User']
  end
end
