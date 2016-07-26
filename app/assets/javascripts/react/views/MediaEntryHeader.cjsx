React = require('react')
ReactDOM = require('react-dom')
HeaderButton = require('./HeaderButton.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
f = require('active-lodash')
SelectCollection = require('./Collection/SelectCollection.cjsx')
AsyncModal = require('./Collection/AsyncModal.cjsx')

module.exports = React.createClass
  displayName: 'MediaEntryHeader'

  getInitialState: () -> {
    active: @props.isClient
    showModal: false
    modalAction: null
  }

  componentWillMount: () ->
    @setState({showModal: @props.showModal})
    @setState({modalAction: @props.modalAction})


  _onClose: () ->
    @setState(showModal: false)

  _onClick: (asyncAction) ->
    @setState(showModal: true, modalAction: asyncAction)

  _contentForGet: (get) ->
    <SelectCollection
      get={get} async={@props.async} authToken={@props.authToken} onClose={@_onClose} />

  _extractGet: (json) ->
    json.header.collection_selection

  render: ({authToken, get} = @props) ->
    # TODO: Outer div should be removed based on the styleguide.
    # This will be possible, as soon as the modal dialog can be added in
    # a higher tree level.

    icon = if get.type == 'Collection' then 'set' else 'media-entry'

    <div style={{margin: '0px', padding: '0px'}}>

      <PageContentHeader icon={icon} title={get.title}>
        {f.map get.buttons, (button) =>
          <HeaderButton key={button.action} onAction={@_onClick} asyncAction={button.async_action}
            icon={button.icon} title={button.title} name={button.action}
            href={button.action} method={button.method} authToken={authToken}/>
        }
      </PageContentHeader>
      {
        if @state.showModal
          if @state.modalAction == 'select_collection'
            getUrl = get.url + '/select_collection?___sparse={"header":{"collection_selection":{}}}'
            <AsyncModal get={get.collection_selection} getUrl={getUrl}
              contentForGet={@_contentForGet} extractGet={@_extractGet} />
          else
            console.error('Unknown modal action: ' + @state.modalAction)
      }
    </div>
