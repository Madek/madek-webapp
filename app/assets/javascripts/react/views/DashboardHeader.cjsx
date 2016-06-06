React = require('react')
ReactDOM = require('react-dom')
PageContentHeader = require('./PageContentHeader.cjsx')
HeaderPrimaryButton = require('./HeaderPrimaryButton.cjsx')
AskModal = require('../ui-components/AskModal.cjsx')
InputFieldText = require('../lib/forms/input-field-text.cjsx')
t = require('../../lib/string-translation.js')('de')
CreateCollection = require('./My/CreateCollection.cjsx')

module.exports = React.createClass
  displayName: 'DashboardHeader'

  getInitialState: () -> {
    active: @props.isClient
    showModal: false
    mounted: false
  }

  componentWillMount: () ->
    @setState({showModal: @props.showModal})

  componentDidMount: () ->
    @setState({mounted: true})


  _onClose: () ->
    @setState(showModal: false)

  _onCreateSetClick: (event) ->
    event.preventDefault()
    @setState(showModal: true)
    return false

  render: ({get, authToken} = @props) ->
    # TODO: Outer div should be removed based on the styleguide.
    # This will be possible, as soon as the modal dialog can be added in
    # a higher tree level.
    dashget = get.hash.user_dashboard
    newget = get.hash.new_collection
    <div style={{margin: '0px', padding: '0px'}}>
      <PageContentHeader icon='home' title={t('sitemap_my_archive')}>
        <HeaderPrimaryButton
          icon={null} text={t('dashboard_create_media_entry_btn')}
          href={dashget.new_media_entry_url} />
        <HeaderPrimaryButton
          icon={'plus'} text={t('dashboard_create_collection_btn')}
          href={dashget.new_collection_url} onClick={@_onCreateSetClick}/>
      </PageContentHeader>
      {
        if @state.showModal
          <CreateCollection get={newget} async={@state.mounted} authToken={authToken} onClose={@_onClose} />

      }
    </div>
