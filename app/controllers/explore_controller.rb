class ExploreController < ApplicationController

  respond_to 'html'

  before_filter do
    @featured_set = MediaSet.featured
    @featured_set_children = @featured_set.child_media_resources.where(:view => true).limit(6) if @featured_set
    @catalog_set = MediaSet.catalog
    @latest_media_entries = MediaResource.media_entries.where(:view => true).limit(6)
    @top_keywords = view_context.hash_for Keyword.with_count.limit(6), {:count => true}
  end

  def index 
    @splashscreen_set = MediaSet.splashscreen
    @splashscreen_set_children = @splashscreen_set.child_media_resources.where(:view => true).shuffle if @splashscreen_set
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
  end

  def categories 
    @catalog_set_categories = @catalog_set.categories.where(:view => true) if @catalog_set
  end
 
  def sections
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @category_set = MediaResource.accessible_by_user(current_user).find(params[:category])
    @category_sections = @category_set.sections view_context.hash_for_filter(@category_set.child_media_resources(current_user), [:meta_data]) if @category_set
  end

  def media_resources 
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @category_set = MediaResource.accessible_by_user(current_user).find(params[:category])
    @category_sections = @category_set.sections view_context.hash_for_filter(@category_set.child_media_resources(current_user), [:meta_data]) if @category_set
    @current_section = @category_sections.detect{|s| s[:name] == params[:section]}
  end

end
