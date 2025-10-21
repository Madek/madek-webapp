import React from 'react'
import BatchRemoveFromSet from './BatchRemoveFromSet.jsx'
import AsyncModal from '../views/Collection/AsyncModal.jsx'
import setUrlParams from '../../lib/set-params-for-url.js'

const BatchRemoveFromSetModal = ({
  get,
  collectionUuid,
  resourceIds,
  returnTo,
  authToken,
  onClose
}) => {
  const contentForGet = get => {
    return (
      <BatchRemoveFromSet
        returnTo={returnTo}
        get={get}
        async={true}
        authToken={authToken}
        onClose={onClose}
      />
    )
  }

  const extractGet = json => {
    return json
  }

  const getUrl = setUrlParams('/batch_ask_remove_from_set', {
    parent_collection_id: collectionUuid,
    resource_id: resourceIds,
    return_to: returnTo
  })

  return (
    <AsyncModal get={get} getUrl={getUrl} contentForGet={contentForGet} extractGet={extractGet} />
  )
}

export default BatchRemoveFromSetModal
module.exports = BatchRemoveFromSetModal
