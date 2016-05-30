React = require('react')

module.exports = React.createClass
  displayName: 'FormButton'

  render: ({text} = @props)->
    <button className="primary-button" type="submit" {...@props}>{text}</button>
