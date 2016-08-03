class ExploreController < ApplicationController

  before_action do
    skip_authorization
  end

  def index
    @get = Presenters::Explore::ExploreMainPage.new(current_user, settings)
    respond_with @get
  end

  def catalog
    @get = Presenters::Explore::ExploreCatalogPage.new(current_user, settings)
    respond_with @get
  end

  def catalog_category
    unless AppSettings.first.catalog_context_keys.include? category_param
      raise ActionController::RoutingError.new(404),
            'Catalog category could not be found.'
    end

    @get = Presenters::Explore::ExploreCatalogCategoryPage.new(current_user,
                                                               settings,
                                                               category_param)
    respond_with @get
  end

  def featured_set
    @get = Presenters::Explore::ExploreFeaturedContentPage.new(current_user,
                                                               settings)
    respond_with @get
  end

  def keywords
    @get = Presenters::Explore::ExploreKeywordsPage.new(current_user, settings)
    respond_with @get
  end

  private

  def category_param
    params.require(:category)
  end

end
