/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')

module.exports = React.createClass({
  displayName: 'Tabs',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken } = param
    return <ul className="ui-tabs large">{this.props.children}</ul>
  }
})
