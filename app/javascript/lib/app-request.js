import {
  includes,
  isEmpty,
  isFunction,
  isNumber,
  isObject,
  isString,
  map,
  merge,
  omit,
} from 'lodash-es';
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// application request helper

// - wraps XHR, converts HTTP into app errors
// - defaults to JSON responses (body argument is parsed)
// - body can be given as `{json: {…}}` instead for auto-stringify
// - shortcut prop for 'sparse' request: `{sparse: {…}}`
// - dynamically get CSRF token (since only used client-side)

import xhr from 'xhr'
import asyncRetry from 'async/retry'
import setParamsForUrl from './set-params-for-url.js'
import getRailsCSRFToken from './rails-csrf-token.js'

// merge headers regardless of casing ('Content-Type' vs. 'content-type')
const mergeHeaders = arrayOfHeaders =>
  arrayOfHeaders
    .map(headers => Object.fromEntries(map(headers, (v, k) => [k.toLowerCase(), v])))
    .reduce((headers, res) => merge(res, headers), {})

export default function (config, callback) {
  let csrfHeader, sparsedUrl
  if (!isObject(config)) {
    throw new TypeError('No config!')
  }
  if (!isString(config.url) || isEmpty(config.url)) {
    throw new TypeError('No URL!')
  }
  if (!isFunction(callback)) {
    throw new TypeError('No callback!')
  }
  if (config.retries && !isNumber(config.retries)) {
    throw new TypeError('Not a number!')
  }
  if (config.delay && !isNumber(config.delay)) {
    throw new TypeError('Not a number!')
  }

  // JSON by default
  const jsonDefaultHeader = { Accept: 'application/json' }

  // CSRF
  if (config.method && !includes(['GET', 'HEAD'], config.method)) {
    csrfHeader = { 'X-CSRF-Token': getRailsCSRFToken() }
  }

  // sparse
  if (!isEmpty(config.sparse)) {
    sparsedUrl = {
      url: setParamsForUrl(config.url, { ___sparse: config.sparse }),
      sparse: null
    }
  }

  // build config & run
  const requestConfig = merge(
    omit(config, ['headers', 'sparse', 'retries']),
    { headers: mergeHeaders([config.headers, jsonDefaultHeader, csrfHeader]) },
    sparsedUrl
  )

  const request = callback =>
    xhr(requestConfig, function (err, res, body) {
      // handle HTTP errors
      if (!err && res.statusCode >= 400) {
        let msg = `Error ${res.statusCode}!`
        if (!isEmpty(res.body)) {
          msg = `${err}\n\n${res.body}`
        }
        err = new Error(msg)
      }

      // handle JSON from response
      const bodyIsStringAndShouldBeJSON =
        isString(body) && includes(res.headers['content-type'], 'application/json')
      if (!err && bodyIsStringAndShouldBeJSON) {
        try {
          body = JSON.parse(body)
        } catch (JSONerror) {
          err = new Error('JSON Error: ' + JSONerror.message)
        }
      }

      return callback(err, { res, body })
    })

  // NOTE: passing around only 1 res for async, extract for the outside caller:
  // this is the place where "opts.success/error"-style callbacks could be supported
  const finalCallback = (err, { res, body }) => callback(err, res, body)

  // optionally support retries. caveat: if used raw xhr request is NOT returned…
  if (config.retries > 1) {
    return asyncRetry(
      { times: config.retries, interval: config.delay || 200 },
      retryCallback => request(retryCallback),
      finalCallback // called after success or when retries exhausted (fail)
    )
  } else {
    return request(finalCallback)
  }
}
