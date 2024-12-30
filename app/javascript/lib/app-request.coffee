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
asyncRetry = require('async/retry')
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
  if (config.retries && !f.isNumber(config.retries)) then throw new TypeError('Not a number!')
  if (config.delay && !f.isNumber(config.delay)) then throw new TypeError('Not a number!')

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
    f.omit(config, ['headers', 'sparse', 'retries']),
    { headers: mergeHeaders([config.headers, jsonDefaultHeader, csrfHeader]) },
    sparsedUrl
  )

  request = (callback)-> xhr(requestConfig, (err, res, body) ->
    # handle HTTP errors
    if (!err && res.statusCode >= 400)
      msg = "Error #{res.statusCode}!"
      if !f.isEmpty(res.body) then msg = "#{err}\n\n#{res.body}"
      err = new Error(msg)

    # handle JSON from response
    bodyIsStringAndShouldBeJSON = f.isString(body) && f.includes(res.headers['content-type'], 'application/json')
    if (!err && bodyIsStringAndShouldBeJSON)
      try
        body = JSON.parse(body)
      catch JSONerror
        err = new Error('JSON Error: ' + JSONerror.message)

    callback(err, {res, body})
  )

  # NOTE: passing around only 1 res for async, extract for the outside caller:
  # this is the place where "opts.success/error"-style callbacks could be supported
  finalCallback = (err, {res, body}) -> callback(err, res, body)

  # optionally support retries. caveat: if used raw xhr request is NOT returned…
  if (config.retries > 1)
    return asyncRetry(
      {times: config.retries, interval: config.delay || 200},
      (retryCallback) => request(retryCallback),
      finalCallback # called after success or when retries exhausted (fail)
    )
  else
    return request(finalCallback)
