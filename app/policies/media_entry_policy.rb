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

  def ask_delete?
    edit?
  end

  def destroy?
    super or allow_for_creator_if_unpublished(record, user)
  end

  def update_custom_urls?
    super and record.is_published
  end

  def add_remove_collection?
    update? and record.is_published
  end

  def select_collection?
    logged_in? and show? and record.is_published
  end

  def permissions_edit?
    super && record.is_published
  end

  def share?
    show? and record.is_published
  end

  alias_method :edit?, :update?

  alias_method :more_data?, :show?
  alias_method :relations?, :show?
  alias_method :browse?, :show?

  alias_method :export?, :show?
  alias_method :embedded?, :show?

  alias_method :meta_data_update?, :update?
  alias_method :edit_meta_data?, :update?
  alias_method :edit_meta_data_by_context?, :update?
  alias_method :edit_meta_data_by_vocabularies?, :update?

  alias_method :relation_parents?, :show?
  alias_method :relation_children?, :show?
  alias_method :relation_siblings?, :show?

  private

  def allow_for_creator_if_unpublished(record, user)
    # NOTE: get real instance in case we got child of vw_media_resources
    record = record.class.find(record.id) unless record.respond_to?(:is_published)
    !record.is_published and record.creator == user
  end

end
