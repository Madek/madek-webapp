React = require('react')
ReactDOM = require('react-dom')
PageContentHeader = require('./PageContentHeader.cjsx')
HeaderPrimaryButton = require('./HeaderPrimaryButton.cjsx')
AskModal = require('../ui-components/AskModal.cjsx')
InputFieldText = require('../lib/forms/input-field-text.cjsx')
t = require('../../lib/string-translation.js')('de')
Models = require('../../models/index.coffee')
CreateCollection = require('./My/CreateCollection.cjsx')

module.exports = React.createClass
  displayName: 'DashboardHeader'

  getInitialState: () -> {
    active: @props.isClient or false
    showCreateSetModal: false
    alerts: null
  }

  componentDidMount: () ->
    model = new Models['Collection']({})
    @setState(model: model)

  _onClose: () ->
    @setState(showCreateSetModal: false)

  _onCreateSetClick: (event) ->
    event.preventDefault()
    @setState(showCreateSetModal: true)
    return false

  render: ({get, authToken} = @props) ->
    # TODO: Outer div should be removed based on the styleguide.
    # This will be possible, as soon as the modal dialog can be added in
    # a higher tree level.
    <div style={{margin: '0px', padding: '0px'}}>
      <PageContentHeader icon='home' title={t('sitemap_my_archive')}>
        <HeaderPrimaryButton
          icon={null} text={t('dashboard_create_media_entry_btn')}
          href={get.new_media_entry_url} />
        <HeaderPrimaryButton
          icon={'plus'} text={t('dashboard_create_collection_btn')}
          href={get.new_collection_url} onClick={@_onCreateSetClick}/>
      </PageContentHeader>
      {
        if @state.showCreateSetModal
          <CreateCollection get={get} async={true} authToken={authToken} onClose={@_onClose} />

      }
    </div>
