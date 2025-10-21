import React from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames/dedupe'
import { parseMods } from '../lib/ui.js'

const ResourceShowOverview = ({ content, preview, previewLg, ...restProps }) => {
  return (
    <div className={cx('ui-resource-overview', parseMods(restProps))}>
      {preview}
      {content}
      {previewLg}
    </div>
  )
}

ResourceShowOverview.propTypes = {
  content: PropTypes.node.isRequired,
  preview: PropTypes.node,
  previewLg: PropTypes.node
}

export default ResourceShowOverview
module.exports = ResourceShowOverview
