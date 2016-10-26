React = require('react')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../../lib/string-translation')('de')
InputFieldText = require('../../lib/forms/input-field-text.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')
ToggableLink = require('../../ui-components/ToggableLink.cjsx')
Modal = require('../../ui-components/Modal.cjsx')
xhr = require('xhr')
formXhr = require('../../../lib/form-xhr.coffee')
appRequest = require('../../../lib/app-request.coffee')
Preloader = require('../../ui-components/Preloader.cjsx')
Button = require('../../ui-components/Button.cjsx')
Icon = require('../../ui-components/Icon.cjsx')

module.exports = React.createClass
  displayName: 'AsyncModal'

  getInitialState: () -> {
    mounted: false
    loading: false
    errors: null
    get: null
    searching: false
    searchTerm: ''
    newSets: []
    children: null
  }

  # TODO Potential problem (class variables).
  lastRequest: null

  componentWillMount: () ->
    if @props.get
      @setState(get: @props.get, children: @props.contentForGet(@props.get))



  componentDidMount: () ->
    @setState({ready: true, mounted: true, loading: true})

    appRequest({ url: @props.getUrl }, (error, result, json) =>
      return unless @isMounted()

      if (error || !json)
        console.error('Cannot load dialog: ' + res.body)
        @setState({loading: false})
      else
        get = @props.extractGet(json)
        @setState(loading: false, get: get, children: @props.contentForGet(get))
    )

  render: ({authToken, get, onClose} = @props) ->

    # TODO: Should this first be rendered with loading false in initial state?
    # if @state.loading or (@props.async and not @state.mounted)
    if not @state.get
      <Modal loading={true} />
    else
      <Modal loading={false}>
        {@state.children}
      </Modal>
