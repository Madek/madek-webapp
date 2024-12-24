React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
PageContent = require('../views/PageContent.cjsx')
TabContent = require('../views/TabContent.cjsx')
Tabs = require('../views/Tabs.cjsx')
Tab = require('../views/Tab.cjsx')
batchDiff = require('../../lib/batch-diff.coffee')
BatchHintBox = require('./BatchHintBox.cjsx')

BatchAddToSet = require('./BatchAddToSet.cjsx')
AsyncModal = require('../views/Collection/AsyncModal.cjsx')
setUrlParams = require('../../lib/set-params-for-url.coffee')

qs = require('qs')
xhr = require('xhr')
Modal = require('../ui-components/Modal.cjsx')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')


module.exports = React.createClass
  displayName: 'BatchAddToSetModal'

  getInitialState: () -> {
    mounted: false,
    loading: true
  }

  componentDidMount: () ->

    data = {
      search_term: '',
      resource_id: @props.resourceIds
      return_to: @props.returnTo
    }

    body = qs.stringify(
      data,
      {
        arrayFormat: 'brackets' # NOTE: Do it like rails.
      }
    )

    xhr(
      {
        url: '/batch_select_add_to_set',
        method: 'POST',
        body: body,
        headers: {
          'Accept': 'application/json',
          'Content-type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, json) =>
        if err || res.statusCode != 200
          return
        else
          @setState(
            get: JSON.parse(json)
            loading: false
          )
    )


  render: ({authToken, get} = @props) ->
    if @state.loading
      <Modal loading={true} />
    else
      <Modal loading={false}>
        <BatchAddToSet returnTo={@props.returnTo}
          get={@state.get} async={true} authToken={@props.authToken} onClose={@props.onClose} />
      </Modal>
