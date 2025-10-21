import React from 'react'
import ResourceThumbnail from './ResourceThumbnail.jsx'

const SimpleResourceThumbnail = ({ type, title, authors_pretty, image_url }) => {
  const get = {
    type,
    title,
    authors_pretty,
    image_url,
    disableLink: true
  }
  // NOTE: no token needed
  return <ResourceThumbnail authToken="" get={get} />
}

export default SimpleResourceThumbnail
module.exports = SimpleResourceThumbnail
