xhr = require('xhr')
getRailsCSRFToken = require('./rails-csrf-token.coffee')
t = require('./string-translation.js')('de')
f = require('lodash')

module.exports = (restForm, callback) ->

  serialized = restForm.serialize()

  xhr(
    {
      method: 'PUT'
      url: restForm.props.action
      body: serialized
      headers: {
        'Accept': 'application/json'
        'Content-type': 'application/x-www-form-urlencoded'
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    (err, res, body) ->

      if err
        callback({result: 'error', type: 'connection-error', message: t('ajax_form_connection_error')})
        return


      if res.statusCode >= 200 && res.statusCode < 300
        data = undefined
        try
          data = JSON.parse(body)
        catch error
          callback({result: 'error', type: 'client-error', message: t('ajax_form_successful_but_parsing_error')})
          return

        if data.forward_url
          callback({result: 'success', type: 'forward', forwardUrl: data.forward_url})
          return

        callback({result: 'success', type: 'data', data: data})
        return


      if res.statusCode == 400

        data = undefined
        try
          data = JSON.parse(body)
        catch error
          callback({result: 'error', type: 'server-error', message: t('ajax_form_validation_error_unparsable')})
          return

        if not data
          callback({result: 'error', type: 'server-error', message: t('ajax_form_validation_error_without_any_data')})
          return

        errors = f.get(data, 'errors')
        if not errors
          callback({result: 'error', type: 'server-error', message: t('ajax_form_validation_error_without_error_data')})
          return

        callback({result: 'error', type: 'validation-error', errors: errors})
        return

      if res.statusCode == 403
        callback({result: 'error', type: 'forbidden', message: t('ajax_form_no_longer_authorized')})
        return



      callback({result: 'error', type: 'server-error', message: t('ajax_form_unexpected_error')})
  )
