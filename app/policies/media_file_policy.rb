class MediaFilePolicy < DefaultPolicy
  def show?
    # use permissions of related MediaEntry:
    return unless (entry = MediaEntry.unscoped.find(record.media_entry_id))

    # either public allowed
    return true if entry.get_full_size?

    # … by 'responsible' role
    return true if user == entry.responsible_user

    # OR via user permissions, BUT only if published!
    return false unless user.present? && entry.is_published

    # … by user permission
    return true if Permissions::MediaEntryUserPermission
      .find_by(user_id: user.id, get_full_size: true, media_entry_id: entry.id)

    # … by group permission
    return true if Permissions::MediaEntryGroupPermission
      .find_by(
        group_id: user.groups.map(&:id),
        get_full_size: true,
        media_entry_id: entry.id)

    # or not
    false
  end
end
