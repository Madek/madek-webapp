# Toolbar inside Box, with Filterbutton, actions, etc.
# In Styleguide it's still called "FilterBar".

React = require('react')
f = require('active-lodash')
{parseMods, cx} = require('../../lib/ui.coffee')
UiPropTypes = require('../propTypes.coffee')

module.exports = React.createClass
  displayName: 'BoxToolBar'
  propTypes:
    left: React.PropTypes.node
    middle: React.PropTypes.node
    right: React.PropTypes.node

  render: (props = @props)->
    {left, middle, right} = @props
    restProps = f.omit(props, ['left', 'middle', 'right'])
    return false unless f.any([left, middle, right], f.present)

    classes = cx('ui-filterbar ui-container separated', parseMods(@props))

    # set grid sizes for right side
    firstColClass = 'col2of6 left'
    middleColClass = 'by-center col2of6'
    lastColClass = 'by-right col2of6'
    setminHeight = {style: {minHeight: '1px'}} # force floating empties!

    <div {...restProps} className={classes}>
      <div {...setminHeight} className={firstColClass}>{left}</div>
      <div {...setminHeight} className={middleColClass}>{middle}</div>
      <div {...setminHeight} className={lastColClass}>{right}</div>
    </div>
