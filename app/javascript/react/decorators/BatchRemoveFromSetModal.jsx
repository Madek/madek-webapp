/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const PageContent = require('../views/PageContent.jsx')
const TabContent = require('../views/TabContent.jsx')
const Tabs = require('../views/Tabs.jsx')
const Tab = require('../views/Tab.jsx')
const batchDiff = require('../../lib/batch-diff.js')
const BatchHintBox = require('./BatchHintBox.jsx')

const BatchRemoveFromSet = require('./BatchRemoveFromSet.jsx')
const AsyncModal = require('../views/Collection/AsyncModal.jsx')
const setUrlParams = require('../../lib/set-params-for-url.js')

module.exports = React.createClass({
  displayName: 'BatchRemoveFromSetModal',

  getInitialState() {
    return {
      mounted: false
    }
  },

  componentWillMount() {},

  _contentForGet(get) {
    return (
      <BatchRemoveFromSet
        returnTo={this.props.returnTo}
        get={get}
        async={true}
        authToken={this.props.authToken}
        onClose={this.props.onClose}
      />
    )
  },

  _extractGet(json) {
    return json
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    const getUrl = setUrlParams('/batch_ask_remove_from_set', {
      parent_collection_id: this.props.collectionUuid,
      resource_id: this.props.resourceIds,
      return_to: this.props.returnTo
    })
    return (
      <AsyncModal
        get={get}
        getUrl={getUrl}
        contentForGet={this._contentForGet}
        extractGet={this._extractGet}
      />
    )
  }
})
