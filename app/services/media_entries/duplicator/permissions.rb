module MediaEntries::Duplicator::Permissions
  private

  def copy_permissions
    copy_user_permissions
    copy_group_permissions
    copy_api_client_permissions
  end

  def copy_user_permissions
    originator.user_permissions.each do |up|
      new_permission = up.dup
      new_permission.media_entry = media_entry
      new_permission.save!
    end
  end

  def copy_group_permissions
    originator.group_permissions.each do |up|
      new_permission = up.dup
      new_permission.media_entry = media_entry
      new_permission.save!
    end
  end

  def copy_api_client_permissions
    originator.api_client_permissions.each do |up|
      new_permission = up.dup
      new_permission.media_entry = media_entry
      new_permission.save!
    end
  end
end
