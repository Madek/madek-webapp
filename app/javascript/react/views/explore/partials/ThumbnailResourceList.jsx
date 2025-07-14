import createReactClass from 'create-react-class'
import React, { Component } from 'react'
import f from 'active-lodash'
import ResourceThumbnail from '../../../decorators/ResourceThumbnail.jsx'

module.exports = createReactClass({
  displayName: 'ThumbnailResourceList',
  render() {
    const { resources, authToken } = this.props

    return (
      <ul className="grid ui-resources">
        {f.map(resources, (resource, n) => (
          <ResourceThumbnail key={`key_${n}`} elm="div" get={resource} authToken={authToken} />
        ))}
      </ul>
    )
  }
})
