/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Rails-style general-purpose form

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import ui from '../../lib/ui.js'
import $ from 'jquery'
import { parse as parseUrl } from 'url'

const checkForAuthToken = function ({ method, authToken }) {
  const restMethod = (method || 'post').toLowerCase()
  const needsAuthToken = !(restMethod === 'get')
  if (!needsAuthToken) {
    return false
  }
  if (!f.present(authToken)) {
    return new Error('No `authToken` given!')
  }
  return authToken
}

module.exports = createReactClass({
  displayName: 'RestForm',
  propTypes: {
    name: PropTypes.string.isRequired,
    action: PropTypes.string,
    method: PropTypes.oneOf([
      'get',
      'GET',
      'post',
      'POST',
      'put',
      'PUT',
      'patch',
      'PATCH',
      'delete',
      'DELETE'
    ]),
    onSubmit: PropTypes.func,
    authToken: PropTypes.string
  },

  // public component method
  serialize() {
    const form = ReactDOM.findDOMNode(this.refs.form)
    return $(form).serialize()
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { name, method, authToken, children } = param
    const ownProps = ['name', 'method', 'authToken', 'children']
    const restProps = f.omit(this.props, ownProps, 'mod', 'mods', 'className')
    const queryParams = parseUrl(f.get(restProps, 'action', ''), true).query

    // Rails conventions:
    // - default method='post'
    const restMethod = (method || 'post').toLowerCase()
    // - emulate the method if browsers don't support it:
    const emulateHTTP = !f.includes(['get', 'post'], restMethod)
    const formMethod = restMethod === 'get' ? 'get' : 'post'
    // - add CRSF token for non-GET methods
    const authTokenParam = 'authenticity_token'
    const maybeAuthToken = checkForAuthToken({ method, authToken })
    // throw to catch erorrs server-side (PropTypes is only for dev)

    return (
      <form
        {...Object.assign({}, restProps, {
          ref: 'form',
          name: name,
          method: formMethod,
          className: ui.cx(ui.parseMods(this.props)),
          acceptCharset: 'UTF-8'
        })}>
        <input name="utf8" type="hidden" value="✓" />
        {f.has(queryParams, 'lang') ? (
          <input name="lang" type="hidden" value={queryParams['lang']} />
        ) : undefined}
        {emulateHTTP ? <input name="_method" type="hidden" value={restMethod} /> : undefined}
        {maybeAuthToken ? (
          <input name={authTokenParam} type="hidden" value={maybeAuthToken} />
        ) : undefined}
        {children}
      </form>
    )
  }
})
