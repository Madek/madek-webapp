/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// ButtonGroup - give buttons as children or props.list

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import UiPropTypes from './propTypes.js'

module.exports = createReactClass({
  displayName: 'ButtonGroup',
  proptypes: {
    list: PropTypes.arrayOf(UiPropTypes.Clickable)
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { children } = param
    const classes = ui.cx(ui.parseMods(this.props), 'button-group')

    // build <Button/>s from given list of props
    // buttons = f(list)
    //   .map((v,k)-> f.assign(v, key: k) if f.present(v))
    //   .sortBy('position')
    //   .map((i)-> f.omit(i, 'position'))
    //   .select((i)-> f(i).omit('key').present())
    //   .map((btn)-> <Button {...btn}/>)
    //   .presence()
    //
    // return unless content = buttons or children

    if (!children) {
      return
    }

    return (
      <div className={classes} data-test-id={this.props['data-test-id']}>
        {children}
      </div>
    )
  }
})
