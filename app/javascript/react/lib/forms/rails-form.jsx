/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Rails-style general-purpose form

const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const ui = require('../../lib/ui.js')
const $ = require('jquery')
const parseUrl = require('url').parse

const checkForAuthToken = function({ method, authToken }) {
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

module.exports = React.createClass({
  displayName: 'RestForm',
  propTypes: {
    name: React.PropTypes.string.isRequired,
    action: React.PropTypes.string,
    method: React.PropTypes.oneOf([
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
    onSubmit: React.PropTypes.func,
    authToken(props, propName, componentName) {
      const check = checkForAuthToken(props)
      // eslint-disable-next-line valid-typeof
      if (typeof check === 'Error') {
        return check
      } else {
        return null
      }
    }
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
    // eslint-disable-next-line valid-typeof
    if (typeof maybeAuthToken === 'Error') {
      throw maybeAuthToken
    }

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
        ) : (
          undefined
        )}
        {emulateHTTP ? <input name="_method" type="hidden" value={restMethod} /> : undefined}
        {maybeAuthToken ? (
          <input name={authTokenParam} type="hidden" value={maybeAuthToken} />
        ) : (
          undefined
        )}
        {children}
      </form>
    )
  }
})
