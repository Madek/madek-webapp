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

    args = [object_id_param, current_user]
    media_entry =
      case object_type_param.to_sym
      when :keywords
        newest_media_entry_with_image_file_for_keyword_and_user(*args)
      when :people
        newest_media_entry_with_image_file_for_person_and_user(*args)
      end

    if media_entry
      redirect_to_preview(media_entry, size_param) and return
    end
    fail 'Searched image for Keyword that has none, this should not happen!'
  end

  # 1st level: thumbnails for keys
  # NOTE: goals:
  # a) pick a thumb that will also be present on the second level (see note there)
  # b) that thumbs next to each other are unique (currently shuffle is enough)
  def catalog_key_thumb
    skip_authorization # only does redirection
    ck = ContextKey.find(category_param)
    meta_key = ck.meta_key

    case meta_key.meta_datum_object_type
    when 'MetaDatum::Keywords'
      keyword = catalog_key_thumb_keyword(meta_key)

      media_entry = newest_media_entry_with_image_file_for_keyword_and_user(
        keyword.id, current_user)
    when 'MetaDatum::People'
      person = catalog_key_thumb_person(meta_key)

      media_entry = newest_media_entry_with_image_file_for_person_and_user(
        person.id, current_user)
    end

    if media_entry
      redirect_to_preview(media_entry, size_param) and return
    end
    fail 'Searched image for Keyword that has none, this should not happen!'
  end

  def catalog_key_thumb_keyword(meta_key)
    Keyword
      .for_meta_key_and_used_in_visible_entries_with_previews(meta_key,
                                                              current_user,
                                                              limit_param)
      .sample
  end

  def catalog_key_thumb_person(meta_key)
    Person
      .for_meta_key_and_used_in_visible_entries_with_previews(meta_key,
                                                              current_user,
                                                              limit_param)
      .sample
  end

  private

  def newest_media_entry_with_image_file_for_keyword_and_user(keyword_id, user)
    auth_policy_scope(user, MediaEntry)
    .joins(:media_file)
    .joins('INNER JOIN previews ON previews.media_file_id = media_files.id')
    .joins(:meta_data)
    .joins('INNER JOIN meta_data_keywords ' \
           'ON meta_data.id = meta_data_keywords.meta_datum_id')
    .where(meta_data_keywords: { keyword_id: keyword_id })
    .where(previews: { media_type: 'image' })
    .reorder('media_entries.meta_data_updated_at DESC')
    .limit(24)
    .sample
  end

  def newest_media_entry_with_image_file_for_person_and_user(person_id, user)
    auth_policy_scope(user, MediaEntry)
    .joins(:media_file)
    .joins('INNER JOIN previews ON previews.media_file_id = media_files.id')
    .joins(:meta_data)
    .joins('INNER JOIN meta_data_people ' \
           'ON meta_data.id = meta_data_people.meta_datum_id')
    .where(meta_data_people: { person_id: person_id })
    .where(previews: { media_type: 'image' })
    .reorder('media_entries.meta_data_updated_at DESC')
    .limit(24)
    .sample
  end

  def redirect_to_preview(media_entry, size)
    imgs = Presenters::MediaFiles::MediaFile.new(media_entry, current_user)
      .try(:previews).try(:[], :images)
    img = imgs.try(:fetch, size, nil) || imgs.try(:values).try(:first)
    redirect_to(img.url)
  end

  def keyword_ids_param
    params.require(:keyword_ids).tap do |ids|
      if ids.blank?
        raise ActionController::UnpermittedParameters,
              'keyword_ids can not be blank!'
      end
    end
  end

  def object_type_param
    params.require(:object_type)
  end

  def object_id_param
    params.require(:object_id)
  end

  def size_param
    params.require(:preview_size)
  end

  def category_param
    params.require(:category)
  end

  def limit_param
    params.require(:limit)
  end

end
