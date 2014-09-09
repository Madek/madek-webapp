module AppAdmin::UsersHelper
  def generate_user_path(path_name, user)
    path = path_name.to_s + '_path'
    path = path.sub(/user_path$/, 'admin_user_path') if user.is_admin?
    send(path, user)
  end
end
