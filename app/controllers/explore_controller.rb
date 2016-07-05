class ExploreController < ApplicationController

  before_action do
    skip_authorization
  end

  def index
    if @feature_toggle_new_explore

      @get = Presenters::Explore::ExploreMainPage.new(current_user, settings)
      respond_with @get

    else

      # simple lists, no interaction, no params
      list_conf = { interactive: false }
      @get = Pojo.new(
        media_entries: Presenters::MediaEntries::MediaEntries.new(
          policy_scope(MediaEntry.all), current_user, list_conf: list_conf),
        collections: Presenters::Collections::Collections.new(
          policy_scope(Collection.all), current_user, list_conf: list_conf))
    end
  end

  # NOTE: following only relevant for @feature_toggle_new_explore

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
