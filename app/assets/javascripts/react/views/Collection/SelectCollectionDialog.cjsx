React = require('react')
ReactDOM = require('react-dom')
getRailsCSRFToken = require('../../../lib/rails-csrf-token.coffee')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../../lib/string-translation')('de')
RailsForm = require('../../lib/forms/rails-form.cjsx')
InputFieldText = require('../../lib/forms/input-field-text.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')
ToggableLink = require('../../ui-components/ToggableLink.cjsx')
Modal = require('../../ui-components/Modal.cjsx')
xhr = require('xhr')
formXhr = require('../../../lib/form-xhr.coffee')
loadXhr = require('../../../lib/load-xhr.coffee')
Preloader = require('../../ui-components/Preloader.cjsx')
Button = require('../../ui-components/Button.cjsx')
Icon = require('../../ui-components/Icon.cjsx')

module.exports = React.createClass
  displayName: 'SelectCollectionDialog'

  _onCancel: (event) ->
    if @props.onCancel
      event.preventDefault()
      @props.onCancel()
      return false
    else
      return true

  render: ({children, onCancel, cancelUrl, title, toolbar, action, authToken, content, method, showSave} = @props) ->
    <div>
      <SelectCollectionHeader onCancel={@_onCancel} cancelUrl={cancelUrl} title={title} />

      <SelectCollectionToolbar>
        {toolbar}
      </SelectCollectionToolbar>


      <SelectCollectionForm action={action} authToken={authToken}
        cancelUrl={cancelUrl} onCancel={@_onCancel} method={method}, showSave={showSave}>

        <SelectCollectionBody>
          {content}
        </SelectCollectionBody>

      </SelectCollectionForm>
    </div>


SelectCollectionHeader = React.createClass
  displayName: 'SelectCollectionHeader'
  render: ({cancelUrl, title, onCancel} = @props) ->
    <div className='ui-modal-head'>
        <a href={cancelUrl} aria-hidden='true'
          className='ui-modal-close' data-dismiss='modal'
          title='Close' type='button'
          style={{position: 'static', float: 'right', paddingTop: '5px'}}
          onClick={onCancel}>
          <i className='icon-close'></i>
        </a>
      <h3 className='title-l'>{title}</h3>
    </div>

SelectCollectionFooter = React.createClass
  displayName: 'SelectCollectionFooter'
  render: ({cancelUrl, onCancel, showSave} = @props) ->
    className = if showSave then 'line weak' else 'primary-button'
    <div className="ui-modal-footer body-lower-limit">
      <div className="ui-actions">
        <a href={cancelUrl} className={className} onClick={onCancel}>
          {t('resource_select_collection_cancel')}</a>
        {
          if showSave
            <Button className="primary-button" type='submit'>
              {t('resource_select_collection_save')}</Button>
        }
      </div>
    </div>

SelectCollectionBody = React.createClass
  displayName: 'SelectCollectionBody'
  render: ({children} = @props) ->
    <div className='ui-modal-body' style={{maxHeight: 'none'}}>
      {children}
    </div>

SelectCollectionForm = React.createClass
  displayName: 'SelectCollectionForm'
  render: ({children, action, authToken, cancelUrl, onCancel, method, showSave} = @props) ->
    <RailsForm name='select_collections' action={action}
            method={method} authToken={authToken} className='dummy' className='save-arcs'>
      {children}
      <SelectCollectionFooter cancelUrl={cancelUrl} onCancel={onCancel} showSave={showSave}/>
    </RailsForm>


SelectCollectionToolbar = React.createClass
  displayName: 'SelectCollectionToolbar'
  render: ({children} = @props) ->
    <div className='ui-modal-toolbar top'>
      {children}
    </div>
