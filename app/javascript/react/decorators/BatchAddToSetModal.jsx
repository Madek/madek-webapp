import React, { useState, useEffect } from 'react'
import BatchAddToSet from './BatchAddToSet.jsx'
import qs from 'qs'
import xhr from 'xhr'
import Modal from '../ui-components/Modal.jsx'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

const BatchAddToSetModal = ({ resourceIds, returnTo, authToken, onClose }) => {
  const [loading, setLoading] = useState(true)
  const [get, setGet] = useState(null)

  useEffect(() => {
    const data = {
      search_term: '',
      resource_id: resourceIds,
      return_to: returnTo
    }

    const body = qs.stringify(data, {
      arrayFormat: 'brackets' // NOTE: Do it like rails.
    })

    xhr(
      {
        url: '/batch_select_add_to_set',
        method: 'POST',
        body,
        headers: {
          Accept: 'application/json',
          'Content-type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, json) => {
        if (err || res.statusCode !== 200) {
          return
        } else {
          setGet(JSON.parse(json))
          setLoading(false)
        }
      }
    )
  }, [resourceIds, returnTo])

  if (loading) {
    return <Modal loading={true} />
  }

  return (
    <Modal loading={false}>
      <BatchAddToSet
        returnTo={returnTo}
        get={get}
        async={true}
        authToken={authToken}
        onClose={onClose}
      />
    </Modal>
  )
}

export default BatchAddToSetModal
module.exports = BatchAddToSetModal
