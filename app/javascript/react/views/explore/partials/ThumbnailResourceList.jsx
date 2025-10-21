import React from 'react'
import ResourceThumbnail from '../../../decorators/ResourceThumbnail.jsx'

const ThumbnailResourceList = ({ resources, authToken }) => {
  return (
    <ul className="grid ui-resources">
      {resources.map((resource, n) => (
        <ResourceThumbnail key={`key_${n}`} elm="div" get={resource} authToken={authToken} />
      ))}
    </ul>
  )
}

export default ThumbnailResourceList
module.exports = ThumbnailResourceList
