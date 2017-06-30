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

  alias_method :batch_remove_from_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_remove_all_from_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_add_all_in_set_to_clipboard?, :batch_add_to_clipboard?
  alias_method :batch_add_all_from_filter_to_clipboard?, :batch_add_to_clipboard?
end
