xhr = require('xhr')
getRailsCSRFToken = require('./rails-csrf-token.coffee')

module.exports = (config, callback) ->
  url = config.url
  body = config.form.serialize()
  if config.method == 'GET'
    url = url + '?' + body
    body = ''

  xhr(
    {
      method: config.method
      url: url
      body: body
      headers: {
        'Accept': 'application/json'
        'Content-type': 'application/x-www-form-urlencoded'
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    (err, res, body) ->

      errors = {
        headers: [],
        fields: {}
      }
      if err
        console.error('Connection problem.', error)
        errors.headers.push('Connection problem.')
        callback('failure', errors)
        return

      try
        data = JSON.parse(body)
      catch error
        console.error('Cannot parse body of answer for meta data update', error)
        errors.headers.push('Cannot parse answer.')
        callback('failure', errors)
        return

      if res.statusCode == 400
        errors.fields = data.errors
        callback('failure', errors)
        return

      callback('success', data)
  )
