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

module.exports = React.createClass
  displayName: 'CreateCollection'

  getInitialState: () -> {
    mounted: false
    saving: false
    errors: null
  }

  _onCancel: (event) ->
    event.preventDefault()
    if @props.onClose
      @props.onClose()
    return false

  _onOk: (event) ->
    event.preventDefault()
    @setState({saving: true, error: null})

    formXhr(
      {
        method: 'POST'
        url: @props.get.submit_url
        form: @refs.form
      },
      (result, json) =>
        return unless @isMounted()
        if result == 'failure'
          @setState(saving: false)
          if json.headers.length > 0
            @setState({error: json.headers[0]})
          else if json.fields.title_mandatory
            @setState({error: json.fields.title_mandatory})
          else
            @setState({error: 'Unknown error.'})
        else
          if @props.onClose
            @props.onClose()
          forward_url = json['forward_url']
          window.location = forward_url
    )

    return false


  render: ({authToken, get, onClose} = @props) ->


    error = @state.error or get.error


    alerts = if error
      <div className="ui-alerts" key='alerts'>
        <p className="ui-alert error">{error}</p>
      </div>


    <RailsForm ref='form' name='resource_meta_data' action={get.submit_url}
          method='post' authToken={authToken}>

      <div className='ui-modal-head'>
        <ToggableLink active={not @state.saving or not @state.mounted} href={get.cancel_url} aria-hidden='true'
          className='ui-modal-close' data-dismiss='modal'
          title='Close' type='button'
          style={{position: 'static', float: 'right', paddingTop: '5px'}}
          onClick={@_onCancel}>
          <i className='icon-close'></i>
        </ToggableLink>
        <h3 className='title-l'>{t('collection_new_dialog_title')}</h3>
      </div>

      <div className='ui-modal-body' style={{maxHeight: 'none'}}>
        {
          if @state.saving
            <Preloader/>
          else
            [
              alerts
              ,
              <div className="form-body" key='form-body'>
                <div className="ui-form-group rowed compact">
                  <label className="form-label">{t('collection_new_label_title')}</label>
                  <div className="form-item">
                    <InputFieldText autocomplete='off' autofocus='autofocus' name='collection_title' value='' />
                  </div>
                </div>
              </div>
            ]
        }
      </div>

      <div className="ui-modal-footer">
        <div className="ui-actions">
          <ToggableLink active={not @state.saving or not @state.mounted} href={get.cancel_url}
            aria-hidden="true" className="link weak"
            data-dismiss="modal" onClick={@_onCancel}>{t('collection_new_cancel')}</ToggableLink>
          <FormButton onClick={@_onOk} disabled={@state.saving} text={t('collection_new_create_set')} />
        </div>
      </div>

    </RailsForm>
