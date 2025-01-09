React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'Tabs'

  render: ({authToken} = @props) ->
    <ul className="ui-tabs large">
      {@props.children}
    </ul>
