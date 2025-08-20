module AllowedSorting

  ALLOWED_SORTING = [
    'created_at ASC',
    'created_at DESC',
    'title ASC',
    'title DESC',
    'last_change ASC',
    'last_change DESC',
    'manual ASC',
    'manual DESC'].freeze

  def allowed_sorting(collection)
    if ALLOWED_SORTING.include? collection.sorting
      collection.sorting
    else
      'created_at DESC'
    end
  end
end
