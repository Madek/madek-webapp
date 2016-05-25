React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'TabContent'
  render: () ->
    <div className="ui-container tab-content bordered rounded-right rounded-bottom mbh">
      {@props.children}
    </div>
