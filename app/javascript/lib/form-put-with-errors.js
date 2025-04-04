/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import xhr from 'xhr'
import getRailsCSRFToken from './rails-csrf-token.js'
import t from './i18n-translate.js'
import f from 'lodash'

module.exports = {
  shared(data, actionUrl, contentType, callback) {
    return xhr(
      {
        method: 'PUT',
        url: actionUrl,
        body: data,
        headers: {
          Accept: 'application/json',
          'Content-type': contentType,
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      function (err, res, body) {
        if (err) {
          callback({
            result: 'error',
            type: 'connection-error',
            message: t('ajax_form_connection_error')
          })
          return
        }

        if (res.statusCode >= 200 && res.statusCode < 300) {
          data = undefined
          try {
            data = JSON.parse(body)

            // eslint-disable-next-line no-unused-vars
          } catch (e) {
            callback({
              result: 'error',
              type: 'client-error',
              message: t('ajax_form_successful_but_parsing_error')
            })
            return
          }

          if (data.forward_url) {
            callback({ result: 'success', type: 'forward', forwardUrl: data.forward_url })
            return
          }

          callback({ result: 'success', type: 'data', data })
          return
        }

        if (res.statusCode === 400) {
          data = undefined
          try {
            data = JSON.parse(body)

            // eslint-disable-next-line no-unused-vars
          } catch (e) {
            callback({
              result: 'error',
              type: 'server-error',
              message: t('ajax_form_validation_error_unparsable')
            })
            return
          }

          if (!data) {
            callback({
              result: 'error',
              type: 'server-error',
              message: t('ajax_form_validation_error_without_any_data')
            })
            return
          }

          const errors = f.get(data, 'errors')
          if (!errors) {
            callback({
              result: 'error',
              type: 'server-error',
              message: t('ajax_form_validation_error_without_error_data')
            })
            return
          }

          callback({ result: 'error', type: 'validation-error', errors })
          return
        }

        if (res.statusCode === 403) {
          callback({
            result: 'error',
            type: 'forbidden',
            message: t('ajax_form_no_longer_authorized')
          })
          return
        }

        return callback({
          result: 'error',
          type: 'server-error',
          message: t('ajax_form_unexpected_error')
        })
      }
    )
  },

  byData(data, actionUrl, callback) {
    return this.shared(JSON.stringify(data), actionUrl, 'application/json', callback)
  },

  byForm(restForm, callback) {
    const serialized = restForm.serialize()

    return this.shared(
      serialized,
      restForm.props.action,
      'application/x-www-form-urlencoded',
      callback
    )
  }
}
