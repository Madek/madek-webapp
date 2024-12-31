React = require('react')
ReactDOM = require('react-dom')
PageContentHeader = require('./PageContentHeader.cjsx')
HeaderPrimaryButton = require('./HeaderPrimaryButton.cjsx')
t = require('../../lib/i18n-translate.js')
CreateCollectionModal = require('./My/CreateCollectionModal.cjsx')

module.exports = React.createClass
  displayName: 'DashboardHeader'

  getInitialState: () -> {
    active: @props.isClient
    showModal: false
    mounted: false
  }

  componentDidMount: () ->
    @setState({mounted: true})


  _onClose: () ->
    @setState(showModal: false)

  _onCreateSetClick: (event) ->
    event.preventDefault()
    @setState(showModal: true)
    return false

  render: ({get, authToken} = @props) ->
    <div style={{margin: '0px', padding: '0px'}}>
      <PageContentHeader icon='home' title={t('sitemap_my_archive')}>
        <HeaderPrimaryButton
          icon={'upload'} text={t('dashboard_create_media_entry_btn')}
          href={get.new_media_entry_url} />
        <HeaderPrimaryButton
          icon={'plus'} text={t('dashboard_create_collection_btn')}
          href={get.new_collection_url} onClick={@_onCreateSetClick}/>
      </PageContentHeader>
      {
        if @state.showModal
          <CreateCollectionModal get={get.new_collection} async={@state.mounted} authToken={authToken}
            onClose={@_onClose} newCollectionUrl={get.new_collection_url} />

      }
    </div>
