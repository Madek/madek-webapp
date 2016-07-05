React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'TabContent'
  render: () ->
    <div className="ui-container tab-content bordered bright rounded-right rounded-bottom">
      {@props.children}
    </div>
