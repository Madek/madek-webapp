import React from 'react'
import PropTypes from 'prop-types'
import ResourcesBoxWithSwitch from '../../templates/ResourcesBoxWithSwitch.jsx'

const MediaEntryIndex = props => {
  return (
    <ResourcesBoxWithSwitch
      saveable={true}
      switches={{ currentType: 'entries', otherTypes: ['sets'] }}
      enableOrdering={true}
      enableOrderByTitle={true}
      usePathUrlReplacement={true}
      {...props}
    />
  )
}

MediaEntryIndex.propTypes = {
  for_url: PropTypes.string.isRequired,
  get: PropTypes.object.isRequired
}

export default MediaEntryIndex
module.exports = MediaEntryIndex
