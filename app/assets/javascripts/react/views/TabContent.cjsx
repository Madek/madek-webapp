React = require('react')
ReactDOM = require('react-dom')
cx = require('classnames')

module.exports = React.createClass
  displayName: 'TabContent'
  render: () ->
    <div className='ui-container tab-content bordered bright rounded-right rounded-bottom' data-test-id={@props.testId}>
      {@props.children}
    </div>
