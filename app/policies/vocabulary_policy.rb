class VocabularyPolicy < DefaultPolicy

  class Scope < Scope
    def resolve
      scope.viewable_by_user_or_public(user)
    end
  end

  class ViewableScope < Scope
  end

  class UsableScope < Scope
    def resolve
      scope.usable_by_user(user)
    end
  end

  def keywords? # just a 'show' tab
    show?
  end

  def contents?
    show?
  end
end
