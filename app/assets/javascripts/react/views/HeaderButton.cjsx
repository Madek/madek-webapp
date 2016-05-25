React = require('react')
ReactDOM = require('react-dom')
RailsForm = require('../lib/forms/rails-form.cjsx')

module.exports = React.createClass
  displayName: 'HeaderButton'
  render: ({authToken, href, method, icon, title, name} = @props) ->
    method = 'post' if not method
    icon = 'icon-' + icon
    <RailsForm className='button_to' name='' method={method} action={href} authToken={authToken}>
      <button className="button" type="submit" title={title}>
        <i className={icon}></i>
      </button>
    </RailsForm>
