import React from 'react'
import { t } from '../lib/ui.js'
import MediaEntryHeaderWithModal from './MediaEntryHeaderWithModal.jsx'
import MediaEntryTabs from './MediaEntryTabs.jsx'
import RelationResources from './Collection/RelationResources.jsx'
import Relations from './Collection/Relations.jsx'
import MediaEntryShow from './MediaEntryShow.jsx'

const BaseTmpReact = ({ get, action_name, for_url, authToken }) => {
  let main

  if (action_name === 'relation_parents') {
    main = <RelationResources get={get} for_url={for_url} scope="parents" authToken={authToken} />
  } else if (action_name === 'relation_siblings') {
    main = <RelationResources get={get} for_url={for_url} scope="siblings" authToken={authToken} />
  } else if (action_name === 'relations') {
    main = <Relations get={get} for_url={for_url} authToken={authToken} />
  } else if (['show', 'show_by_confidential_link'].includes(action_name)) {
    main = <MediaEntryShow get={get} for_url={for_url} authToken={authToken} />
  } else if (['export', 'ask_delete', 'select_collection'].includes(action_name)) {
    main = <MediaEntryShow get={get} for_url={for_url} authToken={authToken} />
  }

  return (
    <div className="app-body-ui-container">
      {action_name === 'show_by_confidential_link' && (
        <div className="ui-alerts" style={{ marginBottom: '10px' }}>
          <div className="confirmation ui-alert">{t('confidential_links_access_notice')}</div>
        </div>
      )}
      <MediaEntryHeaderWithModal get={get} for_url={for_url} authToken={authToken} />
      {action_name !== 'show_by_confidential_link' && (
        <MediaEntryTabs get={get} for_url={for_url} authToken={authToken} />
      )}
      {main}
    </div>
  )
}

export default BaseTmpReact
module.exports = BaseTmpReact
