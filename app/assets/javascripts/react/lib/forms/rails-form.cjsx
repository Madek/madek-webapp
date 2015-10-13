React = require('react')
getToken = require('../../../lib/rails-csrf-token.coffee')

module.exports = React.createClass
  displayName: 'RailsForm'
  componentDidMount: ()-> @setState(token: getToken())

  render: ({name, action, method, token, children} = @props)->
    # token can given by prop (server) or fetched from DOM (browser):
    token = @state?.token || token

    <form name={name} method='post' action={action} acceptCharset='UTF-8'>
      <input name='authenticity_token' type='hidden' value={token}/>
      <input name='_method' type='hidden' value={method || 'post'}/>
      <input name='utf8' type='hidden' value='✓'/>
      {children}
    </form>
