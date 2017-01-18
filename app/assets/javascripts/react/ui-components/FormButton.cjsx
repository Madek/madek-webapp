React = require('react')

module.exports = React.createClass
  displayName: 'FormButton'

  render: ({text, onClick, disabled} = @props)->
    <button className="primary-button" type="submit" onClick={onClick} disabled={disabled}>{text}</button>
