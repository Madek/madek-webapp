class CollectionThumbUrl
  def initialize(collection, user)
    @collection = collection
    @user = user
    @recursed_collections_for_cover = []
  end

  def get(size:)
    cover_media_entry = _choose_media_entry_for_preview
    preview = \
      if cover_media_entry.try(:media_file).present?
        Presenters::MediaFiles::MediaFile.new(cover_media_entry, @user)
        .previews
        .try(:fetch, :images, nil)
        .try(:fetch, size, nil)
      end
    preview.url if preview.present?
  end

  private

  def _choose_media_entry_for_preview(collection = @collection)
    cover = _cover_or_first_media_entry(collection)
    return cover if cover.present?
    # or try recursive search through children
    _cover_from_child_collections(collection)
  end

  def _cover_from_child_collections(collection)
    return if @recursed_collections_for_cover.include?(collection)
    @recursed_collections_for_cover << collection
    # NOTE: two loops because we try all cheaper queries first
    child_collections = collection
    .collections.viewable_by_user_or_public(@user)
    .reorder(created_at: :desc)

    if child_collections.exists?
      # get cover from first level of collection
      child_collections.each do |c|
        cover = _cover_or_first_media_entry(c)
        return cover if cover.present?
      end
      # recurse if not found on this level (and not already searched)
      child_collections.each do |c|
        cover = _cover_from_child_collections(c)
        return cover if cover.present?
      end
      nil # return nil if nothing found anywhere
    end
  end

  def _cover_or_first_media_entry(collection)
    return unless collection.present?

    # return the configured cover if there is one (and it is viewable!)
    if collection.cover.present?
      cover = MediaEntry.viewable_by_user_or_public(@user)
      .find_by_id(collection.cover.id)
      return cover if cover.present?
    end

    # otherwise return the first image-like entry
    collection
    .media_entries
    .viewable_by_user_or_public(@user)
    .reorder(created_at: :desc)
    .each do |entry|
      return entry if entry.media_file.representable_as_image?
    end
    nil # return nil if nothing found
  end
end
