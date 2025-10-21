import React from 'react'
import { t } from '../../lib/ui.js'
import MediaResourcesBox from '../../decorators/MediaResourcesBox.jsx'

const ClipboardBox = props => {
  const { get } = props

  if (!get.clipboard_id) {
    return (
      <div className="pvh mth mbl">
        <div className="by-center">
          <p className="title-l mbm">{t('clipboard_empty_message')}</p>
        </div>
      </div>
    )
  }

  return (
    <MediaResourcesBox
      {...props}
      get={get.resources}
      resourceTypeSwitcherConfig={{ showAll: true }}
      collectionData={{ uuid: get.clipboard_id }}
    />
  )
}

export default ClipboardBox
module.exports = ClipboardBox
