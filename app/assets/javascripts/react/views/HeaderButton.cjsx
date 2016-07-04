# FIXME: remove this

React = require('react')
ReactDOM = require('react-dom')
RailsForm = require('../lib/forms/rails-form.cjsx')

module.exports = React.createClass
  displayName: 'HeaderButton'

  _onClick: (event) ->
    event.preventDefault()
    if @props.onAction
      @props.onAction(@props.asyncAction)
    return false

  render: ({authToken, href, method, icon, title, name} = @props) ->
    method = 'post' if not method
    icon = 'icon-' + icon
    onClick = if @props.onAction and @props.asyncAction then @_onClick else null
    <RailsForm className='button_to' name='' method={method} action={href} authToken={authToken}>
      <button className="button" type="submit" title={title} onClick={onClick}>
        <i className={icon}></i>
      </button>
      {@props.children}
    </RailsForm>
