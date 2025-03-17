/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import xhr from 'xhr'
import getRailsCSRFToken from './rails-csrf-token.js'

module.exports = (config, callback) =>
  xhr(
    {
      method: config.method,
      url: config.url,
      headers: {
        Accept: 'application/json',
        'Content-type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    function (err, res, body) {
      let data
      const errors = {
        headers: [],
        fields: {}
      }
      if (err) {
        console.error('Connection problem.', err)
        errors.headers.push('Connection problem.')
        callback('failure', errors)
        return
      }

      if (res.statusCode > 400) {
        console.error('System error.', res.statusCode)
        errors.headers.push('System error: ' + res.statusCode)
        callback('failure', errors)
        return
      }

      try {
        data = JSON.parse(body)
      } catch (error) {
        console.error('Cannot parse body of answer for meta data update', error)
        errors.headers.push('Cannot parse answer.')
        callback('failure', errors)
        return
      }

      if (res.statusCode === 400) {
        errors.fields = data.errors
        callback('failure', errors)
        return
      }

      return callback('success', data)
    }
  )
