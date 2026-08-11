# scaffolded by Pundit gem
class DefaultPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  def logged_in?
    not user.nil?
  end

  # queries a view-tier uberadmin (uberadmin_view) may bypass;
  # subclasses extend this with their own read-only aliases of show?
  def self.view_tier_queries
    %i(show? index?)
  end
end
