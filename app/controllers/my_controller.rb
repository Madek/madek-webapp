class MyController < ApplicationController

  respond_to 'html'

  before_filter do
    @latest_user_resources_count = (current_user.media_resources).filter(current_user).count
    @latest_user_imports_count = MediaResource.filter(current_user, {:meta_data => {:"uploaded by" => {:ids => [current_user.id]}}}).count
    @user_entrusted_resources_count = MediaResource.filter(current_user).entrusted_to_user(current_user).count
    @user_groups_count = current_user.groups.count
    @user_keywords_count = current_user.keywords.count
    @user_favorite_resources_count = MediaResource.filter(current_user, {:favorites => "true"}).count
  end

  def dashboard
    @latest_user_resources = (current_user.media_resources).filter(current_user).ordered_by(:updated_at).limit(6)
    @latest_user_imports = MediaResource.filter(current_user, {:meta_data => {:"uploaded by" => {:ids => [current_user.id]}}}).ordered_by(:created_at).limit(6)
    @user_entrusted_resources = MediaResource.filter(current_user).entrusted_to_user(current_user).limit(6)
    @user_groups = current_user.groups.limit(4)
    @user_keywords = view_context.hash_for current_user.keywords.with_count.limit(6), {:count => true}
    @user_favorite_resources = MediaResource.filter(current_user, {:favorites => "true"}).limit(12)
  end

  def media_resources
    @my_media_entries_count = current_user.media_entries.count
    @my_media_sets_count = current_user.media_sets.count
  end

  def favorites
  end

  def keywords
    @keywords = view_context.hash_for current_user.keywords.with_count, {:count => true}
  end

  def entrusted_media_resources
  end

  def latest_imports
  end

end
