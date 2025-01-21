/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'

module.exports = createReactClass({
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
