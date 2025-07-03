module CacheHelper
  def cache_key_for_user_menu(user, data)
    "user/#{user.id}/menu-data/#{data.hash}"
  end
end
