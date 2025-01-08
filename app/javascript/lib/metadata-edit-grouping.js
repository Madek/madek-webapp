/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const f = require('active-lodash');

module.exports = {

  // NOTE: Temporary solution for "bundling" of keys. comes from instance config.
  _prefixesForBundle() { return APP_CONFIG.bundle_context_keys || []; },


  _find_exact_in_bundle(meta_key_id) {
    return f.find(this._prefixesForBundle(), prefix => meta_key_id === prefix.group);
  },


  _diff_keys(a, b) {

    const contains_key = (arr, key_id) => f.find(arr, ai => ai.data_id === key_id);

    return f.reject(a, ai => contains_key(b, ai.data_id));
  },


  _reject_followups(keys_to_check, bundle_key) {

    const first_not_matching = f.findIndex(keys_to_check, key => !f.startsWith(key.meta_key_id, bundle_key.prefix));

    if (first_not_matching < 0) { return []; }

    return f.slice(keys_to_check, first_not_matching);
  },


  _group_context_keys(context_keys) {
    const keys = f.map(context_keys, context_key => ({
      meta_key_id: context_key.meta_key_id,
      data_id: context_key.uuid,
      data: context_key
    }));
    return this._group_keys(keys);
  },

  _group_meta_data(meta_data) {
    const keys = f.map(meta_data, meta_datum => ({
      meta_key_id: meta_datum.meta_key_id,
      data_id: meta_datum.meta_key_id,
      data: meta_datum
    }));
    return this._group_keys(keys);
  },


  _group_keys(keys) {
    return this._group_keys_rec({keys_to_check: keys, inter_result: []});
  },



  _group_keys_rec({keys_to_check, inter_result}) {

    if (f.isEmpty(keys_to_check)) {
      return inter_result;
    } else {

      const bundle_key = this._find_exact_in_bundle(f.first(keys_to_check).meta_key_id);

      const rec_keys_to_check =
        bundle_key ?
          this._reject_followups(f.slice(keys_to_check, 1), bundle_key)
        :
          f.slice(keys_to_check, 1);

      const rec_inter_result =
        bundle_key ?
          {
            type: 'block',
            bundle: bundle_key.group,
            mainKey: f.first(this._diff_keys(keys_to_check, rec_keys_to_check)).data,
            content: f.map(f.slice(this._diff_keys(keys_to_check, rec_keys_to_check), 1), entry => entry.data)
          }
        :
          {
            type: 'single',
            content: f.first(keys_to_check).data
          };


      return this._group_keys_rec(
        {
          keys_to_check: rec_keys_to_check,
          inter_result: inter_result.concat([rec_inter_result])
        }
      );
    }
  }

};
