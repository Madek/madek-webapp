/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import cx from 'classnames/dedupe'
import { parseMods } from '../lib/ui.js'

module.exports = createReactClass({
  displayName: 'ResourceShowOverview',
  propTypes: {
    content: PropTypes.node.isRequired,
    preview: PropTypes.node,
    previewLg: PropTypes.node
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { content, preview, previewLg } = param
    return (
      <div className={cx('ui-resource-overview', parseMods(this.props))}>
        {preview ? preview : undefined}
        {content}
        {previewLg ? previewLg : undefined}
      </div>
    )
  }
})
