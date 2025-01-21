/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'

module.exports = createReactClass({
  displayName: 'ActionsBar',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { children } = param
    return <div className="ui-actions">{children}</div>
  }
})
