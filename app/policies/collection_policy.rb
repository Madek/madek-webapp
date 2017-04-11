class CollectionPolicy < Shared::MediaResources::MediaResourcePolicy
  def edit?
    logged_in? and record.editable_by_user?(user)
  end

  def edit_highlights?
    edit?
  end

  def update_highlights?
    edit?
  end

  def edit_cover?
    edit?
  end

  def update_cover?
    edit?
  end

  def ask_delete?
    edit?
  end

  def add_remove_collection?
    update?
  end

  def select_collection?
    update?
  end

  alias_method :batch_add_to_clipboard?, :update?
  alias_method :batch_remove_from_clipboard?, :update?
  alias_method :batch_add_all_in_set_to_clipboard?, :update?
  alias_method :batch_add_all_from_filter_to_clipboard?, :update?

  alias_method :relations?, :show?
  alias_method :more_data?, :show?
  alias_method :context?, :show?
  alias_method :cover?, :show?

  alias_method :relation_parents?, :show?
  alias_method :relation_children?, :show?
  alias_method :relation_siblings?, :show?

  alias_method :edit_meta_data?, :update?
  alias_method :edit_meta_data_by_context?, :update?
  alias_method :edit_meta_data_by_vocabularies?, :update?
  alias_method :meta_data_update?, :update?

  alias_method :batch_add_to_set?, :update?
  alias_method :batch_remove_from_set?, :update?
end
