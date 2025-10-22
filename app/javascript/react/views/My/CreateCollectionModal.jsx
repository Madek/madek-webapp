import React, { useState, useEffect } from 'react'
import Modal from '../../ui-components/Modal.jsx'
import loadXhr from '../../../lib/load-xhr.js'
import CreateCollection from './CreateCollection.jsx'

const CreateCollectionModal = ({ get, newCollectionUrl, authToken, onClose, async }) => {
  const [mounted, setMounted] = useState(false)
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState(get || null)

  useEffect(() => {
    setMounted(true)

    if (!data) {
      setLoading(true)

      loadXhr(
        {
          method: 'GET',
          url: newCollectionUrl
        },
        (result, json) => {
          if (result === 'success') {
            setLoading(false)
            setData(json)
          } else {
            console.error(`Cannot load dialog: ${JSON.stringify(json)}`)
            setLoading(false)
          }
        }
      )
    }
  }, [])

  if (!data) {
    return <Modal loading={true} />
  }

  if (loading || (async && !mounted)) {
    return <Modal loading={true} />
  }

  return (
    <Modal loading={false}>
      <CreateCollection authToken={authToken} get={data} onClose={onClose} />
    </Modal>
  )
}

export default CreateCollectionModal
module.exports = CreateCollectionModal
