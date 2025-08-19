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

  ALIASES = { 'last_change' => 'last_change DESC' }

  def allowed_sorting(collection)
    sorting = ALIASES[collection.sorting] || collection.sorting
    if ALLOWED_SORTING.include? sorting
      sorting
    else
      'created_at DESC'
    end
  end

  def normalize_sortorder(sorting)
    s = ALIASES[sorting] || sorting
    return s if ALLOWED_SORTING.include?(s)
  end
end
