class VocabularyPolicy < DefaultPolicy

  class Scope < Scope
    def resolve
      scope.viewable_by_user_or_public(user)
    end
  end

  def keywords? # just a 'show' tab
    show?
  end
end