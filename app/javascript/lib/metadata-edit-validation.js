/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'

module.exports = {
  _validityForAll(meta_meta_data, models) {
    const mandatory_meta_key_ids = f.keys(meta_meta_data.mandatory_by_meta_key_id)
    return this._validityForMandatoryMetaKeyIds(mandatory_meta_key_ids, models)
  },

  _validityForMandatoryMetaKeyIds(mandatory_meta_key_ids, models) {
    let hasMandatory = false
    let hasInvalid = false
    f.each(mandatory_meta_key_ids, meta_key_id => {
      hasMandatory = true
      const model = models[meta_key_id]
      // Note: The model can be unknown, because you can get more mandatory
      // fields than keys (some are not visible for the user).
      if (model && !this._validModel(model)) {
        return (hasInvalid = true)
      }
    })

    if (!hasMandatory) {
      return 'not_mandatory'
    } else if (hasInvalid) {
      return 'invalid'
    } else {
      return 'valid'
    }
  },

  _validModel(model) {
    if (model.multiple) {
      return model.values.length > 0
    } else {
      if (model.values[0]) {
        return model.values[0].trim().length > 0
      } else {
        return false
      }
    }
  },

  _meta_key_ids_by_context_id(meta_meta_data, context_id) {
    const res = f.map(
      meta_meta_data.context_key_ids_by_context_id[context_id],
      context_key_id => meta_meta_data.meta_key_id_by_context_key_id[context_key_id]
    )
    return res
  },

  _equalUnordered(arr1, arr2, checkUuid) {
    if (arr1.length !== arr2.length) {
      return false
    }

    let equal = true
    f.each(arr1, function (value1) {
      let found = false
      f.each(arr2, function (value2) {
        if (checkUuid === true) {
          if (value1.uuid === value2.uuid) {
            return (found = true)
          }
        } else {
          if (value1 === value2) {
            return (found = true)
          }
        }
      })

      if (found === false) {
        return (equal = false)
      }
    })

    return equal
  },

  _validityForMetaKeyIds(meta_meta_data, models, meta_key_ids) {
    const mandatory_meta_key_ids = f.keys(meta_meta_data.mandatory_by_meta_key_id)
    const reduced_mandatories = f.filter(meta_key_ids, meta_key_id =>
      f.include(mandatory_meta_key_ids, meta_key_id)
    )
    return this._validityForMandatoryMetaKeyIds(reduced_mandatories, models)
  },

  _validityForContext(meta_meta_data, models, context_id) {
    const meta_key_ids = this._meta_key_ids_by_context_id(meta_meta_data, context_id)
    return this._validityForMetaKeyIds(meta_meta_data, models, meta_key_ids)
  },

  _changesPerContext(meta_meta_data, models, context_id) {
    let hasChanges = false
    f.each(models, (model, meta_key_id) => {
      if (
        (context_id &&
          f.includes(this._meta_key_ids_by_context_id(meta_meta_data, context_id), meta_key_id)) ||
        !context_id
      ) {
        if (
          model.multiple !== false ||
          model.originalValues.length !== 0 ||
          model.values.length !== 1 ||
          model.values[0].trim() !== ''
        ) {
          // Note: New keywords have no uuid yet. Fortunately new keywords always mean that the length is different.
          if (!this._equalUnordered(model.values, model.originalValues, model.multiple)) {
            return (hasChanges = true)
          }
        }
      }
    })

    return hasChanges
  }
}
