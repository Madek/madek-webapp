React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'PageContent'

  render: ({title} = @props) ->
    <div className="app-body-ui-container">
      {@props.children}
    </div>
