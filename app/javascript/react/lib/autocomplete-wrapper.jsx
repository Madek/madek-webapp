/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'

let AutoComplete = null

module.exports = createReactClass({
  displayName: 'AutoCompleteWrapper',

  componentDidMount() {
    AutoComplete = require('./autocomplete.js')
    return this.forceUpdate()
  },

  render() {
    return (
      <div>{AutoComplete ? <AutoComplete {...Object.assign({}, this.props)} /> : undefined}</div>
    )
  }
})
