React = require('react')

module.exports = React.createClass
  displayName: 'HeaderPrimaryButton'
  render: ({href, text, icon, onClick} = @props) ->
    <a className="button-primary primary-button" href={href} onClick={onClick}>
      {
        if icon
          <span><i className={'icon-' + icon}></i> </span>
      }
      {text}
    </a>
