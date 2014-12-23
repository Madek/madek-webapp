class MyController < ApplicationController

  LIMIT = 6

  def dashboard
    set_latest
    set_favorites
    set_entrusted
  end

  def set_latest
    @latest_media_entries = \
      current_user.media_entries.reorder('created_at DESC').limit(LIMIT)
    @latest_collections = \
      current_user.collections.reorder('created_at DESC').limit(LIMIT)
    @latest_filter_sets = \
      current_user.filter_sets.reorder('created_at DESC').limit(LIMIT)
    @latest_imports = \
      current_user.created_media_entries.reorder('created_at DESC').limit(LIMIT)
  end

  def set_favorites
    @favorite_media_entries = \
      current_user.favorite_media_entries.limit(LIMIT)
    @favorite_collections = \
      current_user.favorite_collections.limit(LIMIT)
    @favorite_filter_sets = \
      current_user.favorite_filter_sets.limit(LIMIT)
  end

  def set_entrusted
    @entrusted_media_entries = \
      MediaEntry.entrusted_to_user(current_user)
        .reorder('created_at DESC').limit(LIMIT)
    @entrusted_collections = \
      Collection.entrusted_to_user(current_user)
        .reorder('created_at DESC').limit(LIMIT)
    @entrusted_filter_sets = \
      FilterSet.entrusted_to_user(current_user)
        .reorder('created_at DESC').limit(LIMIT)
  end

end
