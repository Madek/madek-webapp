React = require('react')
ReactDOM = require('react-dom')
RailsForm = require('../lib/forms/rails-form.cjsx')

module.exports = React.createClass
  displayName: 'HeaderPrimaryButton'
  render: ({href, text, icon, onClick} = @props) ->
    <a className="button-primary primary-button" href={href} onClick={onClick}>
      {
        if icon
          <i className={'icon-' + icon}></i>
      }
      {text}
    </a>