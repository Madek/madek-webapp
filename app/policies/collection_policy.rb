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
    edit?
  end

  alias_method :relations?, :show?
  alias_method :more_data?, :show?
  alias_method :cover?, :show?

  alias_method :relation_parents?, :show?
  alias_method :relation_children?, :show?
  alias_method :relation_siblings?, :show?

  alias_method :edit_meta_data?, :update?
  alias_method :edit_context_meta_data?, :update?
  alias_method :meta_data_update?, :update?

  alias_method :add_remove_collection?, :update?
  alias_method :select_collection?, :update?

  alias_method :batch_add_to_set?, :update?
  alias_method :batch_remove_from_set?, :update?
end
