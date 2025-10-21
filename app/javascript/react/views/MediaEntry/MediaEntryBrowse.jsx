import React from 'react'
import t from '../../../lib/i18n-translate.js'
import PageHeader from '../../ui-components/PageHeader'
import MetaDataList from '../../decorators/MetaDataList.jsx'
import ResourceThumbnail from '../../decorators//ResourceThumbnail.jsx'
import BrowseEntriesList from './BrowseEntriesList.jsx'

const SideBarContent = ({ get, authToken }) => {
  const { entry } = get
  const summaryContext = get.entry_meta_data.entry_summary_context

  return (
    <div>
      <div className="mbm">
        <ResourceThumbnail get={entry} authToken={authToken} isClient={false} />
      </div>
      <MetaDataList
        mods="ui-media-overview-metadata"
        tagMods="small"
        list={summaryContext}
        showTitle={false}
      />
    </div>
  )
}

const MediaEntryBrowse = ({ get, authToken }) => {
  return (
    <div>
      <PageHeader icon="eye" title={t('browse_entries_title')} />
      <div className="bordered ui-container midtone rounded-right rounded-bottom table">
        <div className="app-body-sidebar table-cell bright ui-container bordered-right rounded-bottom-left table-side">
          <div className="ui-container rounded-left phm pvl">
            <SideBarContent get={get} authToken={authToken} />
            <div className="ui-fadeout-right" role="presentation" />
          </div>
        </div>
        <div className="app-body-content table-cell table-substance ui-container">
          <div className="ui-container pal">
            <BrowseEntriesList browse={get.browse_resources} authToken={authToken} />
          </div>
        </div>
      </div>
    </div>
  )
}

export default MediaEntryBrowse
module.exports = MediaEntryBrowse
