class MyController < ApplicationController

  def dashboard
    limit = 6

    @latest_media_entries = current_user.media_entries.reorder('updated_at DESC').limit(limit)
    @latest_collections = current_user.collections.reorder('updated_at DESC').limit(limit)
    @latest_filter_sets = current_user.filter_sets.reorder('updated_at DESC').limit(limit)

    @latest_imports = current_user.created_media_entries.reorder('created_at DESC').limit(limit)

    @favorite_media_entries = current_user.favorite_media_entries.limit(limit)
    @favorite_collections = current_user.favorite_collections.limit(limit)
    @favorite_filter_sets = current_user.favorite_filter_sets.limit(limit)

    @entrusted_media_entries = MediaEntry.entrusted_to_user(current_user).reorder('updated_at DESC').limit(limit)
    @entrusted_collections = Collection.entrusted_to_user(current_user).reorder('updated_at DESC').limit(limit)
    @entrusted_filter_sets = FilterSet.entrusted_to_user(current_user).reorder('updated_at DESC').limit(limit)
  end

end
