class PreviewPolicy < DefaultPolicy

  def show?
    # apply inherited permissions from related MediaEntry
    entry = MediaEntry.unscoped.find(record.media_file.media_entry_id)
    if !logged_in?
      entry.viewable_by_public?
    else
      entry.viewable_by_user?(user) or (entry.creator == user)
    end
  end

end
