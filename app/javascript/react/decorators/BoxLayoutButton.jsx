import React from 'react'
import Button from '../ui-components/Button.jsx'
import cx from 'classnames/dedupe'
import Icon from '../ui-components/Icon.jsx'

const BoxLayoutButton = ({ layout, onLayoutClick }) => {
  const handleClick = event => {
    onLayoutClick(event, layout)
  }

  const mods = cx('small', 'ui-toolbar-vis-button', layout.mods)

  return (
    <Button
      mode={layout.mode}
      title={layout.title}
      icon={layout.icon}
      href={layout.href}
      onClick={handleClick}
      mods={mods}
      key={layout.mode}>
      <Icon i={layout.icon} title={layout.title} />
    </Button>
  )
}

export default BoxLayoutButton
module.exports = BoxLayoutButton
