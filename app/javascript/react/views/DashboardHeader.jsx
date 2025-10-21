import React, { useState, useEffect } from 'react'
import PageContentHeader from './PageContentHeader.jsx'
import HeaderPrimaryButton from './HeaderPrimaryButton.jsx'
import t from '../../lib/i18n-translate.js'
import CreateCollectionModal from './My/CreateCollectionModal.jsx'

const DashboardHeader = ({ get, authToken }) => {
  const [showModal, setShowModal] = useState(false)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const handleClose = () => {
    setShowModal(false)
  }

  const handleCreateSetClick = event => {
    event.preventDefault()
    setShowModal(true)
    return false
  }

  return (
    <div style={{ margin: '0px', padding: '0px' }}>
      <PageContentHeader icon="home" title={t('sitemap_my_archive')}>
        <HeaderPrimaryButton
          icon="upload"
          text={t('dashboard_create_media_entry_btn')}
          href={get.new_media_entry_url}
        />
        <HeaderPrimaryButton
          icon="plus"
          text={t('dashboard_create_collection_btn')}
          href={get.new_collection_url}
          onClick={handleCreateSetClick}
        />
      </PageContentHeader>
      {showModal && (
        <CreateCollectionModal
          get={get.new_collection}
          async={mounted}
          authToken={authToken}
          onClose={handleClose}
          newCollectionUrl={get.new_collection_url}
        />
      )}
    </div>
  )
}

export default DashboardHeader
module.exports = DashboardHeader
