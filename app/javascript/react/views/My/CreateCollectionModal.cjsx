React = require('react')
ReactDOM = require('react-dom')
Modal = require('../../ui-components/Modal.cjsx')
loadXhr = require('../../../lib/load-xhr.coffee')
CreateCollection = require('./CreateCollection.cjsx')

module.exports = React.createClass
  displayName: 'CreateCollectionModal'

  getInitialState: () -> {
    mounted: false
    loading: false
    get: null
  }

  componentWillMount: () ->
    @setState({get: @props.get, newCollectionUrl: @props.newCollectionUrl})

  componentDidMount: () ->
    @setState({mounted: true})

    if not @state.get
      @setState({loading: true})

      loadXhr(
        {
          method: 'GET'
          url: @state.newCollectionUrl
        },
        (result, json) =>
          return unless @isMounted()
          if result == 'success'
            @setState(loading: false, get: json)
          else
            console.error('Cannot load dialog: ' + JSON.stringify(json))
            @setState({loading: false})
      )



  render: ({authToken, get, onClose} = @props) ->

    if not @state.get
      return <Modal loading={true}/>

    if @state.loading or (@props.async and not @state.mounted)
      return <Modal loading={true} />

    <Modal loading={false}>
      <CreateCollection authToken={authToken} get={@state.get} onClose={onClose} />
    </Modal>
