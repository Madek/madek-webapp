React = require('react')
ReactDOM = require('react-dom')
HeaderButton = require('./HeaderButton.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
f = require('active-lodash')
SelectCollection = require('./Collection/SelectCollection.cjsx')

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

  render: ({authToken, get} = @props) ->
    # TODO: Outer div should be removed based on the styleguide.
    # This will be possible, as soon as the modal dialog can be added in
    # a higher tree level.
    <div style={{margin: '0px', padding: '0px'}}>

      <PageContentHeader icon='set' title={get.title}>
        {f.map get.buttons, (button) =>
          <HeaderButton get={get} key={button.action} onAction={@_onClick} asyncAction={button.async_action}
            icon={button.icon} title={button.title} name={button.action}
            href={button.action} method={button.method} authToken={authToken}/>
        }
      </PageContentHeader>
      {
        if @state.showModal
          if @state.modalAction == 'select_collection'
            search_term = 'sdfsfsd'
            if get.collection_selection
              search_term = get.collection_selection.search_term
            <SelectCollection boot={{url: get.url, search_term: search_term}}
              get={get.collection_selection} async={@props.async} authToken={authToken} onClose={@_onClose} />
          else
            console.error('Unknown modal action: ' + @state.modalAction)
      }
    </div>
