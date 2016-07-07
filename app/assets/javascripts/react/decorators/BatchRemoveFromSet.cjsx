React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
PageContent = require('../views/PageContent.cjsx')
PageContentHeader = require('../views/PageContentHeader.cjsx')
TabContent = require('../views/TabContent.cjsx')
Tabs = require('../views/Tabs.cjsx')
Tab = require('../views/Tab.cjsx')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')
Thumbnail = require('../ui-components/Thumbnail.cjsx')
batchDiff = require('../../lib/batch-diff.coffee')
BatchHintBox = require('./BatchHintBox.cjsx')
ResourcesBatchBox = require('./ResourcesBatchBox.cjsx')
SelectCollectionDialog = require('../views/Collection/SelectCollectionDialog.cjsx')

Button = require('../ui-components/Button.cjsx')
Icon = require('../ui-components/Icon.cjsx')
RailsForm = require('../lib/forms/rails-form.cjsx')
InputFieldText = require('../lib/forms/input-field-text.cjsx')
formXhr = require('../../lib/form-xhr.coffee')
setUrlParams = require('../../lib/set-params-for-url.coffee')
Preloader = require('../ui-components/Preloader.cjsx')
FormButton = require('../ui-components/FormButton.cjsx')

module.exports = React.createClass
  displayName: 'BatchRemoveFromSet'

  _onCancel: (event) ->
    if @props.onCancel
      event.preventDefault()
      @props.onCancel()
      return false
    else
      return true

  _requestUrl: () ->
    setUrlParams(
      @props.get.batch_remove_from_set_url,
      {
        media_entry_id: @props.get.media_entry_ids
        collection_id: @props.get.collection_ids
        return_to: @props.get.return_to
        parent_collection_id: @props.get.parent_collection_id
      }
    )

  getInitialState: () -> {
    mounted: false
  }

  componentWillMount: () ->
    @setState(get: @props.get)

  componentDidMount: () ->
    @setState(mounted: true)

  render: ({get, authToken} = @props) ->

    <RailsForm name='resource_meta_data' action={@_requestUrl()}
          method='patch' authToken={authToken}>

      <input type='hidden' name='return_to' value={@props.get.return_to} />
      <input type='hidden' name='parent_collection_id' value={@props.get.parent_collection_id} />

      <div className='ui-modal-head'>
        <a href={get.return_to} aria-hidden='true'
          className='ui-modal-close' data-dismiss='modal'
          title='Close' type='button'
          style={{position: 'static', float: 'right', paddingTop: '5px'}}>
          <i className='icon-close'></i>
        </a>
        <h3 className='title-l'>{t('batch_remove_from_collection_title')}</h3>
      </div>

      <div className='ui-modal-body' style={{maxHeight: 'none'}}>
        <p className="pam by-center">
          {t('batch_remove_from_collection_hint_pre')}
          <strong>{get.parent_collection_title}</strong>
          {t('batch_remove_from_collection_hint_post')}
        </p>
        <strong style={{marginLeft: '100px'}}>{get.media_entries_count + t('batch_remove_from_collection_media_entries')}</strong>
        <br/>
        <strong style={{marginLeft: '100px'}}>{get.collections_count + t('batch_remove_from_collection_collections')}</strong>
      </div>

      <div className="ui-modal-footer">
        <div className="ui-actions">
          <a href={get.return_to} aria-hidden="true" className="link weak"
            data-dismiss="modal">{t('batch_remove_from_collection_cancel')}</a>
          <FormButton text={t('batch_remove_from_collection_remove')}/>
        </div>
      </div>

    </RailsForm>
