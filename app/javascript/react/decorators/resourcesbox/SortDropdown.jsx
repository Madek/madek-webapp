import React from 'react'
import Dropdown, { MenuItem } from '../../ui-components/Dropdown.jsx'

const SortDropdown = ({ items, selectedKey: initialKey, onItemClick }) => {
  let selectedKey = initialKey
  let selectedItem = items.find(item => item.key === selectedKey)

  if (!selectedItem) {
    selectedKey = items[0].key
    selectedItem = items.find(item => item.key === selectedKey)
  }

  const handleItemClick = (event, itemKey) => {
    if (onItemClick) {
      onItemClick(event, itemKey)
    }
  }

  return (
    <Dropdown mods="stick-right" toggle={selectedItem.label}>
      <Dropdown.Menu className="ui-drop-menu">
        {items.map(item => {
          if (item.key === selectedKey) {
            return null
          }
          return (
            <MenuItem
              key={item.key}
              onClick={event => handleItemClick(event, item.key)}
              href={item.href}>
              {item.label}
            </MenuItem>
          )
        })}
      </Dropdown.Menu>
    </Dropdown>
  )
}

export default SortDropdown
module.exports = SortDropdown
