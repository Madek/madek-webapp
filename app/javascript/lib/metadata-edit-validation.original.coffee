f = require('active-lodash')

module.exports = {
  _validityForAll: (meta_meta_data, models) ->
    mandatory_meta_key_ids = f.keys meta_meta_data.mandatory_by_meta_key_id
    @_validityForMandatoryMetaKeyIds(mandatory_meta_key_ids, models)


  _validityForMandatoryMetaKeyIds: (mandatory_meta_key_ids, models) ->
    hasMandatory = false
    hasInvalid = false
    f.each mandatory_meta_key_ids, (meta_key_id) =>

      hasMandatory = true
      model = models[meta_key_id]
      # Note: The model can be unknown, because you can get more mandatory
      # fields than keys (some are not visible for the user).
      if model and not @_validModel(model)
        hasInvalid = true

    if not hasMandatory
      'not_mandatory'
    else if hasInvalid
      'invalid'
    else
      'valid'


  _validModel: (model) ->
    if model.multiple
      model.values.length > 0
    else
      if model.values[0]
        model.values[0].trim().length > 0
      else
        false

  _meta_key_ids_by_context_id: (meta_meta_data, context_id) ->
    res = f.map(
      meta_meta_data.context_key_ids_by_context_id[context_id],
      (context_key_id) ->
        meta_meta_data.meta_key_id_by_context_key_id[context_key_id]
    )
    res


  _equalUnordered: (arr1, arr2, checkUuid) ->

    if arr1.length != arr2.length
      return false

    equal = true
    f.each(arr1, (value1) ->

      found = false
      f.each(arr2, (value2) ->
        if checkUuid == true
          if(value1.uuid == value2.uuid)
            found = true
        else
          if value1 == value2
            found = true

      )

      if found == false
        equal = false
    )

    return equal




  _validityForMetaKeyIds: (meta_meta_data, models, meta_key_ids) ->
    mandatory_meta_key_ids = f.keys(meta_meta_data.mandatory_by_meta_key_id)
    reduced_mandatories = f.filter(meta_key_ids, (meta_key_id) ->
      f.include(mandatory_meta_key_ids, meta_key_id))
    @_validityForMandatoryMetaKeyIds(reduced_mandatories, models)


  _validityForContext: (meta_meta_data, models, context_id) ->
    meta_key_ids = @_meta_key_ids_by_context_id(meta_meta_data, context_id)
    @_validityForMetaKeyIds(meta_meta_data, models, meta_key_ids)


  _changesPerContext: (meta_meta_data, models, context_id) ->
    hasChanges = false
    f.each models, (model, meta_key_id) =>
      if context_id and (f.includes(@_meta_key_ids_by_context_id(meta_meta_data, context_id), meta_key_id)) or not context_id
        unless model.multiple == false and model.originalValues.length == 0 and model.values.length == 1 and model.values[0].trim() == ''

          # Note: New keywords have no uuid yet. Fortunately new keywords always mean that the length is different.
          if not @_equalUnordered(model.values, model.originalValues, model.multiple)
            hasChanges = true

    hasChanges

  _changesForAll: (meta_meta_data, models) ->
    metadataEditHelper._changesPerContext(meta_meta_data, models, null)


}
