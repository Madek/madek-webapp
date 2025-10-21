import React, { memo } from 'react'
import t from '../../lib/i18n-translate.js'
import Icon from '../ui-components/Icon.jsx'
import Button from '../ui-components/Button.jsx'

const BoxFilterButton = ({ get, config, filterToggleLink, resetFilterLink, _onFilterToggle }) => {
  if (!get.can_filter) {
    return null
  }

  const name = t('resources_box_filter')

  const renderResetFilterLink = () => {
    return resetFilterLink || null
  }

  return (
    <div>
      <Button
        data-test-id="filter-button"
        name={name}
        mods={{ active: config.show_filter }}
        href={filterToggleLink}
        onClick={e => _onFilterToggle(e, !config.show_filter)}>
        <Icon i="filter" mods="small" /> {name}
      </Button>
      {renderResetFilterLink()}
    </div>
  )
}

// Memoize to prevent unnecessary re-renders (replaces shouldComponentUpdate)
export default memo(BoxFilterButton)
module.exports = memo(BoxFilterButton)
