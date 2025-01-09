/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const cx = require('classnames')
const f = require('lodash')
const Icon = require('../ui-components/Icon.jsx')
const { t } = require('../lib/ui.js')

const MediaEntryHeaderWithModal = require('./MediaEntryHeaderWithModal.jsx')
const MediaEntryTabs = require('./MediaEntryTabs.jsx')
const RelationResources = require('./Collection/RelationResources.jsx')
const Relations = require('./Collection/Relations.jsx')
const MediaEntryShow = require('./MediaEntryShow.jsx')

module.exports = React.createClass({
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
