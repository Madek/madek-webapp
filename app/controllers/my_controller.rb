class MyController < ApplicationController

  respond_to 'html'

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
