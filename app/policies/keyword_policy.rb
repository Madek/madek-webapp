class KeywordPolicy < DefaultPolicy

  def show?
    record.meta_key.vocabulary.viewable_by_user?(user)
  end

  class Scope < Scope
    def resolve
      scope.viewable_by_user_or_public(user)
    end
  end
end
