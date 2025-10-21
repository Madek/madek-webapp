// Very minimal Dropdown, with pure-CSS fallback,
// receives toggle content via prop and menu as children.

// It's only responsible for toggling the menu via JS or CSS.

// NOTE: before implementing a more flexible version,
//       check if we could just port (and style!) from boostrap…
//       <https://github.com/react-bootstrap/react-bootstrap>

import React, { useState, useEffect } from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import Icon from './Icon.jsx'
import Link from './Link.jsx'
import Dropdown from 'react-bootstrap/lib/Dropdown'
import MenuItem from 'react-bootstrap/lib/MenuItem'

const UIDropdown = ({ toggle, toggleProps, children, id, mods, testId }) => {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  const fallbackStyles = () => {
    return (
      <style type="text/css">{`\
.ui-dropdown .dropdown-toggle { padding-bottom: 7px }
.dropdown:hover .dropdown-menu { display: block }\
`}</style>
    )
  }

  if (children.props.bsRole !== 'menu') {
    throw new Error('Missing or invalid Menu!')
  }

  const dropdownId = id || `${toggle}_menu`

  return (
    <Dropdown id={dropdownId} className={ui.cx(mods, 'ui-dropdown')} data-test-id={testId}>
      {!isClient && fallbackStyles()}
      <Dropdown.Toggle
        {...{
          componentClass: Link,
          bsClass: 'dropdown-toggle ui-drop-toggle',
          ...toggleProps
        }}>
        {toggle}
        <Icon i="arrow-down stand-alone small" />
      </Dropdown.Toggle>
      {children}
    </Dropdown>
  )
}

UIDropdown.propTypes = {
  toggle: PropTypes.string.isRequired,
  toggleProps: PropTypes.object,
  children: PropTypes.node,
  disabled: PropTypes.bool,
  startOpen: PropTypes.bool
}

UIDropdown.Menu = Dropdown.Menu

UIDropdown.MenuItem = props => {
  const hasLink = props.href || props.onClick
  const isDisabled = props.disabled !== undefined ? props.disabled : !hasLink
  return (
    <MenuItem
      {...{
        componentClass: Link,
        className: 'ui-drop-item',
        disabled: isDisabled,
        ...props
      }}
    />
  )
}
UIDropdown.MenuItem.displayName = 'UIDropdown.MenuItem'

export default UIDropdown
module.exports = UIDropdown
