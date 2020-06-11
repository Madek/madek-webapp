class MetaKeyPolicy < DefaultPolicy
  class Scope < Scope
    def resolve
      scope.viewable_by_user_or_public
    end
  end

  def use_in_md?
    if logged_in?
      vocabulary.usable_by_user?(user)
    else
      vocabulary.usable_by_user_or_public?(user)
    end
  end

  private

  def vocabulary
    record.vocabulary
  end

end
