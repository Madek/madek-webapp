React = require('react')
f = require('active-lodash')
parseMods = require('../../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'RailsForm'
  propTypes:
    name: React.PropTypes.string.isRequired
    action: React.PropTypes.string
    method: React.PropTypes.oneOf(
      ['get', 'GET', 'post', 'POST', 'patch', 'PATCH', 'delete', 'DELETE'])
    authToken: React.PropTypes.string

  render: ({name, action, method, authToken, children} = @props)->
    railsMethod = (method || 'post').toLowerCase()
    formMethod = if (railsMethod is 'get') then 'get' else 'post'
    # fake the method if browsers don't support it:
    emulateHTTP = not f.includes(['get', 'post'], method)
    # add CRSF token for non-GET methods.
    needsAuthToken = method isnt 'get'
    if needsAuthToken && !f.present(authToken)
      throw new Error 'No `authToken` given!'

    <form {...@props}
      name={name} method={formMethod} action={action} className={parseMods(@props)}
      acceptCharset='UTF-8'>

      <input name='utf8' type='hidden' value='✓'/>

      {if emulateHTTP
        <input name='_method' type='hidden' value={railsMethod}/>}

      {if needsAuthToken
        <input name='authenticity_token' type='hidden' value={authToken} />}

      {children}
    </form>
