# Rails-style general-purpose form

React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
$ = require('jquery') # TODO: serializeForm = http://npm.im/form-serialize

module.exports = React.createClass
  displayName: 'RestForm'
  propTypes:
    name: React.PropTypes.string.isRequired
    action: React.PropTypes.string
    method: React.PropTypes.oneOf([
      'get', 'GET', 'post', 'POST', 'put', 'PUT',
      'patch', 'PATCH', 'delete', 'DELETE'])
    authToken: React.PropTypes.string
    onSubmit: React.PropTypes.func

  # public component method
  serialize: () ->
    form = ReactDOM.findDOMNode(@refs.form)
    return $(form).serialize()

  render: ({name, action, method, authToken, onSubmit, children} = @props) ->
    ownProps = ['name', 'action', 'method', 'authToken', 'onSubmit', 'children']
    restProps = f.omit(@props, ownProps)

    # Rails conventions:
    # - default method='post'
    restMethod = (method || 'post').toLowerCase()
    # - emulate the method if browsers don't support it:
    emulateHTTP = not f.includes(['get', 'post'], restMethod)
    formMethod = if (restMethod is 'get') then 'get' else 'post'
    # - add CRSF token for non-GET methods
    needsAuthToken = !(restMethod == 'get')
    authTokenParam = 'authenticity_token'
    if needsAuthToken && !f.present(authToken)
      throw new Error('No `authToken` given!')

    <form {...restProps} ref='form' onSubmit={onSubmit}
      name={name} method={formMethod} action={action}
      className={ui.cx(ui.parseMods(@props))}
      acceptCharset='UTF-8'>

      <input name='utf8' type='hidden' value='✓'/>

      {if emulateHTTP
        <input name='_method' type='hidden' value={restMethod}/>}

      {if needsAuthToken
        <input name={authTokenParam} type='hidden' value={authToken} />}

      {children}
    </form>
