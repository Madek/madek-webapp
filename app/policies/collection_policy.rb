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

  alias_method :add_remove_collection?, :update?
  alias_method :select_collection?, :update?

end
