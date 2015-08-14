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
end
