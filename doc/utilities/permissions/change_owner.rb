def change_owner(resource_type, id, from_user, to_user)
  case resource_type
    when :media_set
      ms = from_user.media_sets.find id
      ms.update_attributes(:user => to_user)
      p = ms.permissions.where(:subject_id => from_user, :subject_type => from_user.class).first
      p.update_attributes(:subject => to_user)
    when :upload_session
      us = from_user.upload_sessions.find id
      us.update_attributes(:user => to_user)
      us.media_entries.each do |me|
        p = me.permissions.where(:subject_id => from_user, :subject_type => from_user.class).first
        p.update_attributes(:subject => to_user)
      end
  end
end

from_user = User.find 10262
to_user = User.find 158401
change_owner(:media_set, 89, from_user, to_user)
change_owner(:upload_session, 213, from_user, to_user)
change_owner(:upload_session, 215, from_user, to_user)

# `rake ts:reindex`