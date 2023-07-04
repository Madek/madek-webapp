class MediaEntryPolicy < Shared::MediaResources::MediaResourcePolicy

  # NOTE: extends all inherited policies to account for unpublished entries

  def show?
    super or allow_for_creator_if_unpublished(record, user)
  end

  def embedded_internally?
    show? || accessed_by_confidential_link?
  end

  def embedded_externally?
    # External embedding is ignoring any *user-specific* permissions!
    # This is to make sure that when a user embed contents somewhere else,
    # it will always work for all other users as well.
    record.viewable_by_public? ||
     accessed_by_confidential_link?
  end

  def fullscreen?
    embedded_internally?
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

  def permissions?
    super || \
      allow_for_creator_if_unpublished(record, user) && record.part_of_workflow? && \
      record.workflow.is_active
  end

  def permissions_edit?
    super && record.is_published
  end

  def share?
    show? and record.is_published and !accessed_by_confidential_link?
  end

  def show_in_admin?
    logged_in? and user.admin?
  end

  def confidential_links?
    logged_in? and responsible_user_or_member_of_delegation? and record.is_published
  end

  def show_by_confidential_link?
    accessed_by_confidential_link?
  end

  # not an action, just a helper
  def _via_personal_access?
    show? and !accessed_by_confidential_link?
  end

  alias_method :more_data?, :_via_personal_access?
  alias_method :relations?, :_via_personal_access?
  alias_method :browse?, :_via_personal_access?
  alias_method :siblings?, :_via_personal_access?
  alias_method :export?, :_via_personal_access?

  alias_method :edit?, :update?
  alias_method :update_file?, :update?

  alias_method :meta_data_update?, :update?
  alias_method :advanced_meta_data_update?, :update?
  alias_method :edit_meta_data?, :update?
  alias_method :edit_meta_data_by_context?, :update?
  alias_method :edit_meta_data_by_vocabularies?, :update?

  alias_method :relation_parents?, :show?
  alias_method :relation_children?, :show?
  alias_method :relation_siblings?, :show?

  alias_method :rdf_export?, :show?

  alias_method :image?, :show?
  alias_method :video?, :show?
  alias_method :audio?, :show?
  alias_method :document?, :show?

  private

  def allow_for_creator_if_unpublished(record, user)
    # NOTE: get real instance in case we got child of vw_media_resources
    record = record.class.find(record.id) unless record.respond_to?(:is_published)
    !record.is_published and record.creator == user
  end

end
