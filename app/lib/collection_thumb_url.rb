class CollectionThumbUrl

  include AuthorizationSetup

  def initialize(collection, user)
    @collection = collection
    @user = user
    @recursed_collections_for_cover = []
  end

  # legacy helper, `get_cover` should be used
  def get(size:)
    cover_previews = get_cover
    preview = cover_previews.try(:fetch, size, nil)
    preview ||= cover_previews.try(:values).try(:first)
    preview.url if preview.present?
  end

  def get_cover
    cover_media_entry = _choose_media_entry_for_preview
    if cover_media_entry.try(:media_file).present?
      Presenters::MediaFiles::MediaFile
        .new(cover_media_entry, @user)
        .try(:previews).try(:[], :images)
    end
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
    child_collections = auth_policy_scope(@user, collection.collections)
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
      cover = auth_policy_scope(@user, MediaEntry)
        .find_by_id(collection.cover.id)
      return cover if cover.present?
    end

    # otherwise return the first image-like entry
    scope = auth_policy_scope(@user, collection.media_entries)
    scope = scope.with_unpublished if collection.part_of_workflow?
    scope
      .reorder(created_at: :desc)
      .each do |entry|
        return entry if entry.try(:media_file).try(:representable_as_image?)
      end

    nil # return nil if nothing found
  end
end
