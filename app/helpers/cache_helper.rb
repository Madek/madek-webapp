module CacheHelper
  def cache_key_for_user_menu(user, data)
    "user/#{user.id}/menu-data/#{data.hash}"
  end

  # def cache_key_for_root(data)
  #   "root-page-data/#{data.hash}"
  # end

  def cache_key_for_root_latest_media_entry(media_entry)
    "root-latest-media-entry/#{media_entry.created_at.to_i}"
  end
end
