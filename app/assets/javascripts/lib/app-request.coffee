# application request helper

# - wraps XHR, converts HTTP into app errors
# - defaults to JSON responses (body argument is parsed)
# - body can be given as `{json: {…}}` instead for auto-stringify
# - shortcut prop for 'sparse' request: `{sparse: {…}}`
# - dynamically get CSRF token (since only used client-side)

# TODO: detect & handle aborted requests?
#       - detect: headers are empty; maybe request.status is useful?
#       - handle: how? isnt it up to the consumer? maybe a special error?

# TODO: support config.success and config.errors as callback alternative?

xhr = require('xhr')
parseHeaders = require('parse-headers')
f = require('active-lodash')
setParamsForUrl = require('./set-params-for-url.coffee')
getRailsCSRFToken = require('./rails-csrf-token.coffee')

# merge headers regardless of casing ('Content-Type' vs. 'content-type')
mergeHeaders = (arrayOfHeaders) ->
  arrayOfHeaders
    .map((headers) -> f.object(f.map(headers, (v, k) -> [k.toLowerCase(), v])))
    .reduce(((headers, res) -> f.merge(res, headers)), {})

module.exports = (config, callback) ->
  if (!f.isObject(config)) then throw new TypeError('No config!')
  if (!f.isString(config.url) || f.isEmpty(config.url)) then throw new TypeError('No URL!')
  if (!f.isFunction(callback)) then throw new TypeError('No callback!')

  # JSON by default
  jsonDefaultHeader = { 'Accept': 'application/json' }

  # CSRF
  if (config.method && !f.includes(['GET', 'HEAD'], config.method))
    csrfHeader = { 'X-CSRF-Token': getRailsCSRFToken() }

  # sparse
  if (!f.isEmpty(config.sparse))
    sparsedUrl = {
      url: setParamsForUrl(config.url, {___sparse: config.sparse}),
      sparse: null
    }

  # build config & run
  requestConfig = f.merge(
    f.omit(config, ['headers']),
    { headers: mergeHeaders([config.headers, jsonDefaultHeader, csrfHeader]) },
    sparsedUrl
  )

  return xhr(requestConfig, (err, res, body) ->
    # handle HTTP errors
    if (!err && res.statusCode >= 400)
      msg = "Error #{res.statusCode}!"
      if !f.isEmpty(res.body) then msg = "#{err}\n\n#{res.body}"
      err = new Error("#{res.statusCode}: res.body")

    # handle JSON from response
    if (!err && f.includes(res.headers['content-type'], 'application/json'))
      try
        body = JSON.parse(body)
      catch JSONerror
        err = new Error('JSON Error: ' + JSONerror.message)

    callback(err, res, body)
  )
