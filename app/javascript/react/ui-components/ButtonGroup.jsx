// ButtonGroup - give buttons as children or props.list

import React from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import UiPropTypes from './propTypes.js'

const ButtonGroup = props => {
  const { children } = props
  const classes = ui.cx(ui.parseMods(props), 'button-group')

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
    return null
  }

  return (
    <div className={classes} data-test-id={props['data-test-id']}>
      {children}
    </div>
  )
}

ButtonGroup.proptypes = {
  list: PropTypes.arrayOf(UiPropTypes.Clickable)
}

export default ButtonGroup
module.exports = ButtonGroup
