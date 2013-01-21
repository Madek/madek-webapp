class ExploreController < ApplicationController

  respond_to 'html'

  before_filter do
    @featured_set = MediaSet.featured
    @featured_set_children = @featured_set.child_media_resources.accessible_by_user(current_user).ordered_by(:updated_at).limit(6) if @featured_set
    @catalog_set = MediaSet.catalog
    @any_top_keywords = Keyword.with_count_for_accessible_media_resources(current_user).exists?
  end

  def index 
    @splashscreen_set = MediaSet.splashscreen
    @splashscreen_set_children = @splashscreen_set.child_media_resources.where(:view => true).shuffle if @splashscreen_set
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @top_keywords = view_context.hash_for Keyword.with_count_for_accessible_media_resources(current_user).limit(12), {:count => true}
  end

  def catalog
    @catalog_set_categories = @catalog_set.categories.where(:view => true) if @catalog_set
  end
 
  def category
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @category_set = MediaResource.accessible_by_user(current_user).find(params[:category])
    @category_sections = @category_set.sections view_context.hash_for_filter(@category_set.child_media_resources(current_user), [:meta_data]) if @category_set
  end

  def section
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @category_set = MediaResource.accessible_by_user(current_user).find(params[:category])
    @category_sections = @category_set.sections view_context.hash_for_filter(@category_set.child_media_resources(current_user), [:meta_data]) if @category_set
    @current_section = @category_sections.detect{|s| s[:name] == params[:section]}
  end

  def featured_set
    @featured_set_children = @featured_set.child_media_resources.accessible_by_user(current_user).ordered_by(:updated_at) if @featured_set
  end

  def keywords
    @keywords = view_context.hash_for Keyword.with_count_for_accessible_media_resources(current_user).limit(200), {:count => true}
  end

end
