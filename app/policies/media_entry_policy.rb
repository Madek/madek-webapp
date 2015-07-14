class MediaEntryPolicy < Shared::MediaResources::MediaResourcePolicy

  def show?
    super or (!record.is_published and record.creator == user)
  end

end
