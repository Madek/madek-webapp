class UserPolicy < DefaultPolicy

  def toggle_uberadmin?
    user.admin?
  end

  def set_list_config?
    logged_in?
  end

  def batch_add_to_clipboard?
    logged_in?
  end

  # BETA FEATURES
  def beta_test_new_browse?
    return false unless beta_testers_group_id = UUIDTools::UUID.sha1_create(
      Madek::Constants::MADEK_UUID_NS, 'beta_test_new_browse').to_s
    return false unless beta_testers = Group.find_by(id: beta_testers_group_id)
    logged_in? and beta_testers.users.include?(user)
  end

  alias_method :batch_remove_from_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_remove_all_from_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_add_all_in_set_to_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_add_all_from_filter_to_clipboard?, :batch_add_to_clipboard?
end
