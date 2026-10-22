class PreviewPolicy < DefaultPolicy

  def hls_file?
    show?
  end

  def hls_package?
    show?
  end

  def show?
    return true if record.accessed_by_confidential_link
    # apply inherited permissions from related MediaEntry
    entry = MediaEntry.unscoped.find(record.media_file.media_entry_id)
    if !logged_in?
      entry.viewable_by_public?
    else
      entry.viewable_by_user?(user) or (entry.creator == user)
    end
  end

end
