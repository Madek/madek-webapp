def change_owner(resource_type, id, from_user, to_user)
  case resource_type
  when :media_set
    change_owner_for_media_set!(id, from_user, to_user)
  when :upload_session
    change_owner_for_upload_session!(id, from_user, to_user)
  end
end

def change_owner_for_media_set!(id, from_user, to_user)
  ms = from_user.media_sets.find id
  ms.update(user: to_user)
  update_permission_subject_for_resource!(ms, from_user, to_user)
end

def change_owner_for_upload_session!(id, from_user, to_user)
  us = from_user.upload_sessions.find id
  us.update(user: to_user)
  us.media_entries.each do |me|
    update_permission_subject_for_resource!(me, from_user, to_user)
  end
end

def update_permission_subject_for_resource!(resource, from_user, to_user)
  p = \
    resource
      .permissions
      .where(subject_id: from_user, subject_type: from_user.class)
      .first
  p.update(subject: to_user)
end

from_user = User.find 10262
to_user = User.find 158401
change_owner(:media_set, 89, from_user, to_user)
change_owner(:upload_session, 213, from_user, to_user)
change_owner(:upload_session, 215, from_user, to_user)

# `rake ts:reindex`
