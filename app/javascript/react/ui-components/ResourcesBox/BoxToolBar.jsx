/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Toolbar inside Box, with Filterbutton, actions, etc.
// In Styleguide it's still called "FilterBar".

const React = require('react')
const f = require('active-lodash')
const { parseMods, cx } = require('../../lib/ui.js')
const UiPropTypes = require('../propTypes.js')

module.exports = React.createClass({
  displayName: 'BoxToolBar',
  propTypes: {
    left: React.PropTypes.node,
    middle: React.PropTypes.node,
    right: React.PropTypes.node
  },

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    const { left, middle, right } = this.props
    const restProps = f.omit(props, ['left', 'middle', 'right'])
    if (!f.any([left, middle, right], f.present)) {
      return false
    }

    const classes = cx('ui-filterbar ui-container separated', parseMods(this.props))

    // set grid sizes for right side
    const firstColClass = 'col2of6 left'
    const middleColClass = 'by-center col2of6'
    const lastColClass = 'by-right col2of6'
    const setminHeight = { style: { minHeight: '1px' } } // force floating empties!

    return (
      <div {...Object.assign({}, restProps, { className: classes })}>
        <div {...Object.assign({}, setminHeight, { className: firstColClass })}>{left}</div>
        <div {...Object.assign({}, setminHeight, { className: middleColClass })}>{middle}</div>
        <div {...Object.assign({}, setminHeight, { className: lastColClass })}>{right}</div>
      </div>
    )
  }
})
