/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const f = require('lodash');

const equal_meta_data_values = function(set_a, set_b, attribute) {

  // Compare the two arrays. First copy both, then remove iteratively an
  // element from A and remove the same in B. If it is not in B, they are not
  // equal.

  // First check the lengths.
  if (set_a.length !== set_b.length) {
    return false;
  }

  // Copy both arrays.
  const rest_a = f.map(set_a, el_a => el_a);
  const rest_b = f.map(set_b, el_b => el_b);

  // Remove element from array A...
  while (rest_a.length > 0) {
    var el_a = rest_a.pop();

    // ... and search same element in array B and remove it if it is found.
    var found_b = false;
    var to_remove_b = null;
    f.each(rest_b, function(el_b, index_b) {
      if (!found_b) {
        if (attribute === null) {
          if (el_a === el_b) { found_b = true; }
        } else {
          if (el_a[attribute] === el_b[attribute]) { found_b = true; }
        }
        if (found_b) { return to_remove_b = index_b; }
      }
    });

    // If the element is not found in array B, they are not equal.
    if (!found_b) {
      return false;
    } else {
      rest_b.splice(to_remove_b, 1);
    }
  }

  return true;
};

const compare_datums = function(datum_a, datum_b) {

  let both_empty = false;
  let both_equal = false;

  if ((datum_a.values.length === 0) && (datum_b.values.length === 0)) {
    both_empty = true;
    both_equal = true;
  } else if (datum_a.values.length !== datum_b.values.length) {
    both_empty = false;
    both_equal = false;
  } else if ((datum_a.type === "MetaDatum::Text") || (datum_a.type === "MetaDatum::TextDate")) {
    both_equal = equal_meta_data_values(datum_a.values, datum_b.values, null);
  } else {
    both_equal = equal_meta_data_values(datum_a.values, datum_b.values, 'uuid');
  }

  return {
    both_empty,
    both_equal
  };
};

const compare_datum_between_entries = function(meta_key_id, reference_datum, all_entries) {

  let all_empty = true;
  let all_equal = true;

  // Note: We take the datum of the first entry as the reference datum.
  // We do not explicitly check if we compare the entry against itself,
  // since this does not change the result.

  f.each(all_entries, function(entry, index) {

    const other = entry.meta_data.meta_datum_by_meta_key_id[meta_key_id];

    // "other" may never be null.

    const diff_d_res = compare_datums(reference_datum, other);
    if (!diff_d_res.both_empty) {
      all_empty = false;
    }
    if (!diff_d_res.both_equal) {
      return all_equal = false;
    }
  });

  return {
    all_empty,
    all_equal
  };
};



const compare_all = function(all_meta_keys, all_entries) {

  const keys = f.map(all_meta_keys, (meta_key, meta_key_id) => meta_key_id);

  const values = f.map(keys, function(meta_key_id) {
    const first_datum = all_entries[0].meta_data.meta_datum_by_meta_key_id[meta_key_id];
    return compare_datum_between_entries(meta_key_id, first_datum, all_entries);
  });

  return f.zipObject(keys, values);
};



module.exports = (all_meta_keys, all_entries) => compare_all(all_meta_keys, all_entries);
