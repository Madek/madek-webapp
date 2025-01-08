/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const classList = require('classnames/dedupe')
const { parseMods } = require('../lib/ui.js')

module.exports = React.createClass({
  displayName: 'ResourceShowOverview',
  propTypes: {
    content: React.PropTypes.node.isRequired,
    preview: React.PropTypes.node,
    previewLg: React.PropTypes.node
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { content, preview, previewLg } = param
    return (
      <div className={classList('ui-resource-overview', parseMods(this.props))}>
        {preview ? preview : undefined}
        {content}
        {previewLg ? previewLg : undefined}
      </div>
    )
  }
})
