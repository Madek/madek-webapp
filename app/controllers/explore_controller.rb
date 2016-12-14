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

  # lazy-loading thumbnails: search and *redirect to* media files

  # 2nd level: thumb for keywords of keys
  # NOTE: the *newest* entry (with an image) is used,
  # so that the entry can be found on the 3rd level (index view, also by newest)
  def catalog_key_item_thumb
    skip_authorization # only redirect, no auth needed here

    media_entry = \
      newest_media_entry_with_image_file_for_keyword_and_user(keyword_id_param,
                                                              current_user)

    if media_entry
      preview = media_entry.media_file.preview(preview_size_param)
      redirect_to preview_path(preview)
    else
      fail 'Searched image for Keyword that has none, this should not happen!'
    end
  end

  # 1st level: thumbnails for keys
  # NOTE: goals:
  # a) pick a thumb that will also be present on the second level (see note there)
  # b) that thumbs next to each other are unique (currently shuffle is enough)
  def catalog_key_thumb
    skip_authorization # only does redirection
    ck = ContextKey.find(category_param)

    keyword = \
      Keyword.with_usage_count
      .for_meta_key_and_used_in_visible_entries_with_previews(ck.meta_key,
                                                              current_user,
                                                              limit_param)
      .sample

    media_entry = newest_media_entry_with_image_file_for_keyword_and_user(
      keyword.id, current_user)

    if media_entry
      preview = media_entry.media_file.preview(preview_size_param)
      redirect_to preview_path(preview)
    else
      fail 'Searched image for Keyword that has none, this should not happen!'
    end
  end

  private

  def newest_media_entry_with_image_file_for_keyword_and_user(keyword_id, user)
    MediaEntryPolicy::ViewableScope.new(user, MediaEntry).resolve
    .joins(:media_file)
    .joins('INNER JOIN previews ON previews.media_file_id = media_files.id')
    .joins(:meta_data)
    .joins('INNER JOIN meta_data_keywords ' \
           'ON meta_data.id = meta_data_keywords.meta_datum_id')
    .where(meta_data_keywords: { keyword_id: keyword_id })
    .where(previews: { media_type: 'image' })
    .reorder('media_entries.created_at DESC')
    .first
  end

  def keyword_id_param
    params.require(:keyword_id)
  end

  def keyword_ids_param
    params.require(:keyword_ids).tap do |ids|
      if ids.blank?
        raise ActionController::UnpermittedParameters,
              'keyword_ids can not be blank!'
      end
    end
  end

  def preview_size_param
    params.require(:preview_size)
  end

  def category_param
    params.require(:category)
  end

  def limit_param
    params.require(:limit)
  end

end
