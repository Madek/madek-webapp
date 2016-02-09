class MetaKeyPolicy < DefaultPolicy
  class Scope < Scope
    def resolve
      scope.viewable_by_user_or_public
    end
  end
end
