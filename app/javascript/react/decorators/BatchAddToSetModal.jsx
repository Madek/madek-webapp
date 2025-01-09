/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const PageContent = require('../views/PageContent.cjsx')
const TabContent = require('../views/TabContent.cjsx')
const Tabs = require('../views/Tabs.cjsx')
const Tab = require('../views/Tab.cjsx')
const batchDiff = require('../../lib/batch-diff.js')
const BatchHintBox = require('./BatchHintBox.cjsx')

const BatchAddToSet = require('./BatchAddToSet.cjsx')
const AsyncModal = require('../views/Collection/AsyncModal.cjsx')
const setUrlParams = require('../../lib/set-params-for-url.js')

const qs = require('qs')
const xhr = require('xhr')
const Modal = require('../ui-components/Modal.cjsx')
const getRailsCSRFToken = require('../../lib/rails-csrf-token.js')

module.exports = React.createClass({
  displayName: 'BatchAddToSetModal',

  getInitialState() {
    return {
      mounted: false,
      loading: true
    }
  },

  componentDidMount() {
    const data = {
      search_term: '',
      resource_id: this.props.resourceIds,
      return_to: this.props.returnTo
    }

    const body = qs.stringify(data, {
      arrayFormat: 'brackets' // NOTE: Do it like rails.
    })

    return xhr(
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
          return this.setState({
            get: JSON.parse(json),
            loading: false
          })
        }
      }
    )
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    if (this.state.loading) {
      return <Modal loading={true} />
    } else {
      return (
        <Modal loading={false}>
          <BatchAddToSet
            returnTo={this.props.returnTo}
            get={this.state.get}
            async={true}
            authToken={this.props.authToken}
            onClose={this.props.onClose}
          />
        </Modal>
      )
    }
  }
})
