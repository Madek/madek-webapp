class MediaEntryPolicy < Shared::MediaResources::MediaResourcePolicy

  # NOTE: extends all inherited policies to account for unpublished entries

  def show?
    super or allow_for_creator_if_unpublished(record, user)
  end

  def update?
    super or allow_for_creator_if_unpublished(record, user)
  end

  def publish?
    allow_for_creator_if_unpublished(record, user)
  end

  def destroy?
    super or allow_for_creator_if_unpublished(record, user)
  end

  alias_method :more_data?, :show?
  alias_method :relations?, :show?

  alias_method :meta_data_update?, :update?
  alias_method :edit_meta_data?, :update?
  alias_method :add_remove_collection?, :update?
  alias_method :select_collection?, :update?

  private

  def allow_for_creator_if_unpublished(record, user)
    !record.is_published and record.creator == user
  end

end
