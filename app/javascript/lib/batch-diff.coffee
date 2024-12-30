f = require('lodash')

equal_meta_data_values = (set_a, set_b, attribute) ->

  # Compare the two arrays. First copy both, then remove iteratively an
  # element from A and remove the same in B. If it is not in B, they are not
  # equal.

  # First check the lengths.
  if set_a.length != set_b.length
    return false

  # Copy both arrays.
  rest_a = f.map set_a, (el_a) ->
    el_a
  rest_b = f.map set_b, (el_b) ->
    el_b

  # Remove element from array A...
  while rest_a.length > 0
    el_a = rest_a.pop()

    # ... and search same element in array B and remove it if it is found.
    found_b = false
    to_remove_b = null
    f.each rest_b, (el_b, index_b) ->
      if not found_b
        if attribute == null
          found_b = true if el_a == el_b
        else
          found_b = true if el_a[attribute] == el_b[attribute]
        to_remove_b = index_b if found_b

    # If the element is not found in array B, they are not equal.
    if not found_b
      return false
    else
      rest_b.splice(to_remove_b, 1)

  return true

compare_datums = (datum_a, datum_b) ->

  both_empty = false
  both_equal = false

  if datum_a.values.length == 0 && datum_b.values.length == 0
    both_empty = true
    both_equal = true
  else if datum_a.values.length != datum_b.values.length
    both_empty = false
    both_equal = false
  else if datum_a.type == "MetaDatum::Text" or datum_a.type == "MetaDatum::TextDate"
    both_equal = equal_meta_data_values(datum_a.values, datum_b.values, null)
  else
    both_equal = equal_meta_data_values(datum_a.values, datum_b.values, 'uuid')

  return {
    both_empty: both_empty,
    both_equal: both_equal
  }

compare_datum_between_entries = (meta_key_id, reference_datum, all_entries) ->

  all_empty = true
  all_equal = true

  # Note: We take the datum of the first entry as the reference datum.
  # We do not explicitly check if we compare the entry against itself,
  # since this does not change the result.

  f.each(all_entries, (entry, index) ->

    other = entry.meta_data.meta_datum_by_meta_key_id[meta_key_id]

    # "other" may never be null.

    diff_d_res = compare_datums(reference_datum, other)
    if not diff_d_res.both_empty
      all_empty = false
    if not diff_d_res.both_equal
      all_equal = false
  )

  return {
    all_empty: all_empty,
    all_equal: all_equal
  }



compare_all = (all_meta_keys, all_entries) ->

  keys = f.map all_meta_keys, (meta_key, meta_key_id) ->
    meta_key_id

  values = f.map keys, (meta_key_id) ->
    first_datum = all_entries[0].meta_data.meta_datum_by_meta_key_id[meta_key_id]
    compare_datum_between_entries(meta_key_id, first_datum, all_entries)

  f.zipObject keys, values



module.exports = (all_meta_keys, all_entries) ->
  compare_all(all_meta_keys, all_entries)
