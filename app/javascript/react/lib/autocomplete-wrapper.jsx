/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')

let AutoComplete = null

module.exports = React.createClass({
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
