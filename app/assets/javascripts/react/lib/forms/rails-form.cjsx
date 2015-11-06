React = require('react')
f = require('active-lodash')
getToken = require('../../../lib/rails-csrf-token.coffee')
parseMods = require('../../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'RailsForm'
  componentDidMount: ()-> @setState(authToken: getToken())

  render: ({name, action, method, token, children} = @props)->
    # token can given by prop (server) or fetched from DOM (browser):
    authToken = @state?.authToken || authToken
    railsMethod = (method || 'post').toLowerCase()
    formMethod = if (railsMethod is 'get') then 'get' else 'post'

    <form {...@props}
      name={name} method={formMethod} action={action} className={parseMods(@props)}
      acceptCharset='UTF-8'>

      <input name='utf8' type='hidden' value='✓'/>

      {if not (f.includes(['get', 'post'], method)) # "emulate http":
        <input name='_method' type='hidden' value={railsMethod}/>}

      {if not (method is 'get') # CSRF:
        <input name='authenticity_token' type='hidden' value={authToken}/>}

      {children}
    </form>
