f = require('active-lodash')

module.exports = {

  # NOTE: Temporary solution for "bundling" of keys. comes from instance config.
  _prefixesForBundle: () -> APP_CONFIG.bundle_context_keys || []


  _find_exact_in_bundle: (meta_key_id) ->
    f.find @_prefixesForBundle(), (prefix) ->
      meta_key_id == prefix.group


  _diff_keys: (a, b) ->

    contains_key = (arr, key_id) ->
      f.find arr, (ai) ->
        ai.uuid == key_id

    f.reject a, (ai) ->
      contains_key(b, ai.uuid)


  _reject_followups: (keys_to_check, bundle_key) ->

    first_not_matching = f.findIndex keys_to_check, (key) ->
      not f.startsWith(key.meta_key_id, bundle_key.prefix)

    return [] if first_not_matching < 0

    f.slice keys_to_check, first_not_matching



  _group_keys: ({keys_to_check, inter_result}) ->

    if f.isEmpty(keys_to_check)
      inter_result
    else

      bundle_key = @_find_exact_in_bundle(f.first(keys_to_check).meta_key_id)

      rec_keys_to_check =
        if bundle_key
          @_reject_followups(f.slice(keys_to_check, 1), bundle_key)
        else
          f.slice(keys_to_check, 1)

      rec_inter_result =
        if bundle_key
          {
            type: 'block'
            bundle: bundle_key.group
            mainKey: f.first(@_diff_keys(keys_to_check, rec_keys_to_check))
            content: f.slice(@_diff_keys(keys_to_check, rec_keys_to_check), 1)
          }
        else
          {
            type: 'single'
            content: f.first(keys_to_check)
          }


      @_group_keys(
        {
          keys_to_check: rec_keys_to_check,
          inter_result: inter_result.concat([rec_inter_result])
        }
      )

}
