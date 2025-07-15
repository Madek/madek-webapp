import createReactClass from 'create-react-class'
import React from 'react'
import f from 'active-lodash'
import CatalogResource from './CatalogResource.jsx'

module.exports = createReactClass({
  displayName: 'CatalogResourceList',
  render() {
    const { resources, authToken } = this.props

    return (
      <ul className="grid ui-resources" style={{ marginBottom: '40px', marginTop: '0px' }}>
        {f.map(resources, (resource, n) => {
          return <CatalogResource key={`key_${n}`} resource={resource} authToken={authToken} />
        })}
      </ul>
    )
  }
})
