import React, { useState, useEffect, useRef } from 'react'
import Modal from '../../ui-components/Modal.jsx'
import loadXhr from '../../../lib/load-xhr.js'

const AsyncModal = ({ get: initialGet, getUrl, contentForGet, extractGet, widthInPixel }) => {
  const [get, setGet] = useState(initialGet || null)
  const [children, setChildren] = useState(initialGet ? contentForGet(initialGet) : null)
  const isMountedRef = useRef(true)

  useEffect(() => {
    // Always make the XHR request, even if initialGet was provided
    loadXhr(
      {
        method: 'GET',
        url: getUrl
      },
      (result, json) => {
        if (!isMountedRef.current) {
          return
        }
        if (result === 'success') {
          const fetchedGet = extractGet(json)
          setGet(fetchedGet)
          setChildren(contentForGet(fetchedGet))
        } else {
          console.error(`Cannot load dialog: ${JSON.stringify(json)}`)
        }
      }
    )

    return () => {
      isMountedRef.current = false
    }
  }, [getUrl, extractGet, contentForGet])

  if (!get) {
    return <Modal loading={true} widthInPixel={widthInPixel} />
  }

  return (
    <Modal loading={false} widthInPixel={widthInPixel}>
      {children}
    </Modal>
  )
}

export default AsyncModal
module.exports = AsyncModal
