/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'

module.exports = createReactClass({
  displayName: 'FormButton',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { text, onClick, disabled } = param
    return (
      <button className="primary-button" type="submit" onClick={onClick} disabled={disabled}>
        {text}
      </button>
    )
  }
})
