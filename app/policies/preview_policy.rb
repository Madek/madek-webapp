class PreviewPolicy < DefaultPolicy
  def preview?
    entry = MediaEntry.unscoped.find(record.media_file.media_entry_id)
    # TODO: check for full size permission
    entry.viewable_by_user?(user) or (entry.creator == user)
  end
end
