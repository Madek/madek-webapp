/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const cx = require('classnames')

module.exports = React.createClass({
  displayName: 'TabContent',
  render() {
    return (
      <div
        className="ui-container tab-content bordered bright rounded-right rounded-bottom"
        data-test-id={this.props.testId}>
        {this.props.children}
      </div>
    )
  }
})
