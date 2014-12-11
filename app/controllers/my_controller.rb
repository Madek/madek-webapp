class MyController < ApplicationController

  def dashboard
    @latest_media_entries = current_user.media_entries.reorder("updated_at DESC").limit(6)
    @latest_collections = current_user.collections.reorder("updated_at DESC").limit(6)

    @favorite_media_entries = current_user.favorite_media_entries.limit(6)
    @favorite_collections = current_user.favorite_collections.limit(6)
  end

end
