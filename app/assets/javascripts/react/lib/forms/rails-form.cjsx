# Rails-style general-purpose form

React = require('react')
f = require('active-lodash')
parseMods = require('../../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'RestForm'
  propTypes:
    name: React.PropTypes.string.isRequired
    action: React.PropTypes.string
    method: React.PropTypes.oneOf(
      ['get', 'GET', 'post', 'POST', 'patch', 'PATCH', 'delete', 'DELETE'])
    authToken: React.PropTypes.string

  render: ({name, action, method, authToken, children} = @props)->
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

    <form {...@props}
      name={name} method={formMethod} action={action} className={parseMods(@props)}
      acceptCharset='UTF-8'>

      <input name='utf8' type='hidden' value='✓'/>

      {if emulateHTTP
        <input name='_method' type='hidden' value={restMethod}/>}

      {if needsAuthToken
        <input name={authTokenParam} type='hidden' value={authToken} />}

      {children}
    </form>
