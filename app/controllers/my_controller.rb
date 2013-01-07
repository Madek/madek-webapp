class MyController < ApplicationController

  respond_to 'html'

  before_filter do
    @latest_user_resources = (current_user.media_resources).filter(current_user).ordered_by(:updated_at).limit(6)
    @user_favorite_resources = MediaResource.filter(current_user, {:favorites => "true"}).limit(12)
    @user_keywords = view_context.hash_for current_user.keywords.with_count.limit(6), {:count => true}
    @user_groups = current_user.groups.limit(4)
    @user_entrusted_resources = MediaResource.filter(current_user).entrusted_to_user(current_user).limit(6)
  end

  def media_resources
    @my_media_entries_count = current_user.media_entries.count
    @my_media_sets_count = current_user.media_sets.count
  end

  def favorites
    @favored_media_resources_count = current_user.favorites.count
  end

  def keywords
    @keywords = view_context.hash_for current_user.keywords.with_count, {:count => true}
  end

  def entrusted_media_resources
    @entrusted_media_resources_count = MediaResource.filter(current_user, {:permissions => {:scope => {:ids => ["entrusted"]}}}).count
  end

end
