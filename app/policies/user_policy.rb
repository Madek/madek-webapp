class UserPolicy < DefaultPolicy

  def index?
    logged_in?
  end
  
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
  def beta_test_quick_edit?
    id = Madek::Constants::BETA_TESTERS_QUICK_EDIT_GROUP_ID
    return false unless beta_testers_group = Group.find_by(id: id)
    logged_in? and beta_testers_group.users.include?(user)
  end

  alias_method :batch_remove_from_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_remove_all_from_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_add_all_in_set_to_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_add_all_from_filter_to_clipboard?, :batch_add_to_clipboard?
end
