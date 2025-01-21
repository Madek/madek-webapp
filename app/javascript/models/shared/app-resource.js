/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import Model from 'ampersand-model'
import xhr from 'xhr'
import f from 'active-lodash'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import RailsResource from './rails-resource-mixin.js'

const customDataTypes = {
  // tri-state, can be true, false or 'mixed'
  trilean: {
    compare(a, b) {
      return a === b
    },
    set(newVal) {
      if (f.includes([true, false, 'mixed'], newVal)) {
        return { val: newVal, type: 'trilean' }
      } else {
        return { val: newVal, type: `'${newVal}' (${typeof newVal})` }
      }
    }
  }
}

// Base class for Restful Application Resources
module.exports = Model.extend(RailsResource, {
  type: 'AppResource',
  idAttribute: 'url',
  typeAttribute: 'type', // see presenter{.rb,s/shared/app_resource.rb}
  dataTypes: customDataTypes,
  props: {
    url: 'string',
    uuid: 'string'
  },

  save(config) {
    return Model.prototype.save.call(this, {}, f.defaults({}, config, { wait: true }))
  },

  // update props of type object, triggers 'change'
  merge(prop, data) {
    return this.set(prop, f.merge(this.get(prop), data))
  },

  // shortcut, like presenter:
  dump() {
    return Model.prototype.serialize.call(this, arguments)
  },

  // ajax helper
  _runRequest(req, callback) {
    return xhr(
      {
        method: req.method,
        url: req.url,
        body: req.body,
        beforeSend: req.beforeSend,
        headers: {
          Accept: 'application/json',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      function(err, res, body) {
        const data =
          (() => {
            try {
              return JSON.parse(body)
            } catch (error) {
              // this is OK, just fallback to unparsed body
            }
          })() || body
        return callback(err, res, data)
      }
    )
  }
})
