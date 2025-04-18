/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'lodash'
import { t } from '../lib/ui.js'
import MediaEntryHeaderWithModal from './MediaEntryHeaderWithModal.jsx'
import MediaEntryTabs from './MediaEntryTabs.jsx'
import RelationResources from './Collection/RelationResources.jsx'
import Relations from './Collection/Relations.jsx'
import MediaEntryShow from './MediaEntryShow.jsx'

module.exports = createReactClass({
  displayName: 'BaseTmpReact',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, action_name, for_url, authToken } = param
    const main = (() => {
      if (action_name === 'relation_parents') {
        return (
          <RelationResources get={get} for_url={for_url} scope="parents" authToken={authToken} />
        )
      } else if (action_name === 'relation_siblings') {
        return (
          <RelationResources get={get} for_url={for_url} scope="siblings" authToken={authToken} />
        )
      } else if (action_name === 'relations') {
        return <Relations get={get} for_url={for_url} authToken={authToken} />
      } else if (f.includes(['show', 'show_by_confidential_link'], action_name)) {
        return <MediaEntryShow get={get} for_url={for_url} authToken={authToken} />
      } else if (f.includes(['export', 'ask_delete', 'select_collection'], action_name)) {
        return <MediaEntryShow get={get} for_url={for_url} authToken={authToken} />
      }
    })()

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
})
