import React from 'react'
import CatalogResource from './CatalogResource.jsx'

const CatalogResourceList = ({ resources, authToken }) => {
  return (
    <ul className="grid ui-resources" style={{ marginBottom: '40px', marginTop: '0px' }}>
      {resources.map((resource, n) => {
        return <CatalogResource key={`key_${n}`} resource={resource} authToken={authToken} />
      })}
    </ul>
  )
}

export default CatalogResourceList
module.exports = CatalogResourceList
