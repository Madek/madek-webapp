class MediaEntryPolicy < Shared::MediaResources::MediaResourcePolicy

  def show?
    super or (!record.is_published and record.creator == user)
  end

  alias_method :more_data?, :show?
  alias_method :relations?, :show?

  def destroy?
    record.editable_by_user?(user) or \
      (!record.is_published and record.creator == user)
  end

  def meta_data_update?
    record.editable_by_user?(user)
  end
end
