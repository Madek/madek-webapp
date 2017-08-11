React = require('react')
ReactDOM = require('react-dom')
getRailsCSRFToken = require('../../../lib/rails-csrf-token.coffee')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../../lib/i18n-translate.js')
RailsForm = require('../../lib/forms/rails-form.cjsx')
InputFieldText = require('../../lib/forms/input-field-text.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')
ToggableLink = require('../../ui-components/ToggableLink.cjsx')
Modal = require('../../ui-components/Modal.cjsx')
xhr = require('xhr')
formXhr = require('../../../lib/form-xhr.coffee')
loadXhr = require('../../../lib/load-xhr.coffee')
Preloader = require('../../ui-components/Preloader.cjsx')
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
