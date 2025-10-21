import React from 'react'
import PropTypes from 'prop-types'
import ResourcesBoxWithSwitch from '../../templates/ResourcesBoxWithSwitch.jsx'

const CollectionIndex = props => {
  return (
    <ResourcesBoxWithSwitch
      saveable={true}
      switches={{ currentType: 'sets', otherTypes: ['entries'] }}
      enableOrdering={true}
      enableOrderByTitle={true}
      usePathUrlReplacement={true}
      {...props}
    />
  )
}

CollectionIndex.propTypes = {
  for_url: PropTypes.string.isRequired,
  get: PropTypes.object.isRequired
}

export default CollectionIndex
module.exports = CollectionIndex
