// Toolbar inside Box, with Filterbutton, actions, etc.
// In Styleguide it's still called "FilterBar".

import React from 'react'
import PropTypes from 'prop-types'
import { parseMods, cx } from '../../lib/ui.js'
import { present } from '../../../lib/utils.js'

const BoxToolBar = ({ left, middle, right, ...restProps }) => {
  if (![left, middle, right].some(present)) {
    return null
  }

  const classes = cx('ui-filterbar ui-container separated', parseMods(restProps))

  // set grid sizes for right side
  const firstColClass = 'col2of6 left'
  const middleColClass = 'by-center col2of6'
  const lastColClass = 'by-right col2of6'
  const setminHeight = { style: { minHeight: '1px' } } // force floating empties!

  return (
    <div {...restProps} className={classes}>
      <div {...setminHeight} className={firstColClass}>
        {left}
      </div>
      <div {...setminHeight} className={middleColClass}>
        {middle}
      </div>
      <div {...setminHeight} className={lastColClass}>
        {right}
      </div>
    </div>
  )
}

BoxToolBar.propTypes = {
  left: PropTypes.node,
  middle: PropTypes.node,
  right: PropTypes.node
}

export default BoxToolBar
module.exports = BoxToolBar
