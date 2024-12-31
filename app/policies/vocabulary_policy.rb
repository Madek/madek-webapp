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

  def keyword_term?
    show?
  end

  def redirect_by_term?
    show?
  end

  # 'show' page tabs:

  def keywords?
    show?
  end

  def people?
    logged_in? and show?
  end

  def contents?
    show?
  end

  def permissions?
    show?
  end

  def permissions_update?
    false # can NOT be edited via webapp like Entries etc.
  end
end
