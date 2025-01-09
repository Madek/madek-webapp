# Rails-style general-purpose form

React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
ui = require('../../lib/ui.js')
$ = require('jquery')
parseUrl = require('url').parse

checkForAuthToken = ({method, authToken}) ->
  restMethod = (method || 'post').toLowerCase()
  needsAuthToken = !(restMethod == 'get')
  if !needsAuthToken then return false
  if !f.present(authToken) then return new Error('No `authToken` given!')
  return authToken

module.exports = React.createClass
  displayName: 'RestForm'
  propTypes:
    name: React.PropTypes.string.isRequired
    action: React.PropTypes.string
    method: React.PropTypes.oneOf([
      'get', 'GET', 'post', 'POST', 'put', 'PUT',
      'patch', 'PATCH', 'delete', 'DELETE'])
    onSubmit: React.PropTypes.func
    authToken: (props, propName, componentName) ->
      check = checkForAuthToken(props)
      return if typeof check is 'Error' then check else null

  # public component method
  serialize: () ->
    form = ReactDOM.findDOMNode(@refs.form)
    return $(form).serialize()

  render: ({name, method, authToken, children} = @props) ->
    ownProps = ['name', 'method', 'authToken', 'children']
    restProps = f.omit(@props, ownProps, 'mod', 'mods', 'className')
    queryParams = parseUrl(f.get(restProps, 'action', ''), true).query

    # Rails conventions:
    # - default method='post'
    restMethod = (method || 'post').toLowerCase()
    # - emulate the method if browsers don't support it:
    emulateHTTP = not f.includes(['get', 'post'], restMethod)
    formMethod = if (restMethod is 'get') then 'get' else 'post'
    # - add CRSF token for non-GET methods
    authTokenParam = 'authenticity_token'
    maybeAuthToken = checkForAuthToken({method, authToken})
    # throw to catch erorrs server-side (PropTypes is only for dev)
    if typeof maybeAuthToken is 'Error' then throw maybeAuthToken

    <form {...restProps} ref='form'
      name={name} method={formMethod}
      className={ui.cx(ui.parseMods(@props))}
      acceptCharset='UTF-8'>

      <input name='utf8' type='hidden' value='✓'/>

      {if f.has(queryParams, 'lang')
        <input name='lang' type='hidden' value={queryParams['lang']}/>
      }

      {if emulateHTTP
        <input name='_method' type='hidden' value={restMethod}/>}

      {if maybeAuthToken
        <input name={authTokenParam} type='hidden' value={maybeAuthToken} />}

      {children}
    </form>
