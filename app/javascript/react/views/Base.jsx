import React from 'react'
import t from '../../lib/i18n-translate.js'
import MediaEntryHeaderWithModal from './MediaEntryHeaderWithModal.jsx'
import MediaEntryTabs from './MediaEntryTabs.jsx'
import MetaDataByListing from '../decorators/MetaDataByListing.jsx'
import MediaEntryPermissions from './MediaEntry/MediaEntryPermissions.jsx'
import MediaEntryUsageData from './MediaEntry/MediaEntryUsageData.jsx'

const Base = ({ get, action_name, for_url, authToken }) => {
  const main = (() => {
    if (action_name === 'more_data') {
      return (
        <div className="ui-container">
          <h3 className="title-l mbl">{t('media_entry_all_metadata_title')}</h3>
          <MetaDataByListing
            list={get.meta_data.by_vocabulary}
            hideSeparator={true}
            authToken={authToken}
          />
        </div>
      )
    } else if (['permissions', 'permissions_edit'].includes(action_name)) {
      return <MediaEntryPermissions get={get.permissions} for_url={for_url} authToken={authToken} />
    } else if (action_name === 'usage_data') {
      return <MediaEntryUsageData get={get} for_url={for_url} authToken={authToken} />
    }
  })()

  return (
    <div className="app-body-ui-container">
      <MediaEntryHeaderWithModal get={get} for_url={for_url} authToken={authToken} />
      <MediaEntryTabs get={get} for_url={for_url} authToken={authToken} />
      <div className="ui-container tab-content bordered rounded-right rounded-bottom mbh">
        <div className="ui-container bright pal rounded-top-right rounded-bottom">{main}</div>
      </div>
    </div>
  )
}

export default Base
