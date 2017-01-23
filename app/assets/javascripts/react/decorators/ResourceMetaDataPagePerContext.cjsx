React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
setUrlParams = require('../../lib/set-params-for-url.coffee')

Button = require('../ui-components/Button.cjsx')
Icon = require('../ui-components/Icon.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
Picture = require('../ui-components/Picture.cjsx')
BatchHintBox = require('./BatchHintBox.cjsx')
ResourcesBatchBox = require('./ResourcesBatchBox.cjsx')
PageContent = require('../views/PageContent.cjsx')
PageContentHeader = require('../views/PageContentHeader.cjsx')
TabContent = require('../views/TabContent.cjsx')
Tabs = require('../views/Tabs.cjsx')
Tab = require('../views/Tab.cjsx')

batchDiff = require('../../lib/batch-diff.coffee')

React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
xhr = require('xhr')
cx = require('classnames')
t = require('../../lib/string-translation.js')('de')
setUrlParams = require('../../lib/set-params-for-url.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
MadekPropTypes = require('../lib/madek-prop-types.coffee')

InputMetaDatum = require('./InputMetaDatum.cjsx')
MetaKeyFormLabel = require('../lib/forms/form-label.cjsx')

validation = require('../../lib/metadata-edit-validation.coffee')
grouping = require('../../lib/metadata-edit-grouping.coffee')
Renderer = require('./metadataedit/MetadataEditRenderer.cjsx')

module.exports = React.createClass
  displayName: 'ResourceMetaDataPagePerContext'

  _onTabClick: (context_id, event) ->
    event.preventDefault()
    @setState({currentContextId: context_id})
    return false

  getInitialState: () -> {
    mounted: false
    currentContextId: null
    models: {}
    batchDiff: {}
    editing: false
    errors: {}
    saving: false
    systemError: false
    bundleState: {}
  }

  _actionUrl: () ->
    automaticPublish = validation._validityForAll(
      @props.get.meta_meta_data, @state.models) == 'valid' and @state.mounted == true and not @props.get.published
    if automaticPublish
      actionType = 'publish'
    else
      actionType = 'save'


    url = @props.get.url + '/meta_data'

    if @props.batch
      actionType = 'save'
      url = @props.get.submit_url

    url = url + '?actionType=' + actionType

    # Note: Return to must be a hidden field to for the server-side case.
    # Url parameters are ignored in the <form action=... field.
    url = setUrlParams(url, {return_to: @props.get.return_to})



  _createModelForMetaKey: (meta_key) ->
    {
      multiple: not (meta_key.value_type == "MetaDatum::Text" or meta_key.value_type == "MetaDatum::TextDate")
      meta_key: meta_key
      values: []
      originalValues: []
    }

  _createaModelsForMetaKeys: (meta_meta_data, meta_data, diff) ->
    models = f.mapValues meta_meta_data.meta_key_by_meta_key_id, (meta_key) =>
      @_createModelForMetaKey(meta_key)

    f.each meta_data.existing_meta_data_by_meta_key_id, (data, meta_key_id) ->
      models[meta_key_id].values = data.values

    f.each models, (model) ->
      model.originalValues = f.map model.values, (value) ->
        value

    if diff
      f.each models, (model, meta_key_id) ->
        unless diff[meta_key_id].all_equal
          model.originalValues = []
          model.values = []

    return models


  _determineCurrentContextId: (context_id, meta_meta_data) ->
    currentContextId = context_id
    if currentContextId == null
      currentContextId = meta_meta_data.meta_data_edit_context_ids[0]
    return currentContextId




  componentDidMount: () ->
    @setState({mounted: true})


  componentWillMount: () ->

    currentContextId = @_determineCurrentContextId(@props.get.context_id, @props.get.meta_meta_data)
    @setState({currentContextId: currentContextId})

    if @props.batch
      diff = batchDiff(@props.get.meta_meta_data.meta_key_by_meta_key_id, @props.get.batch_entries)
      @setState({batchDiff: diff})

    models = @_createaModelsForMetaKeys(@props.get.meta_meta_data, @props.get.meta_data, diff)
    @setState({models: models})




  _onChangeForm: (meta_key_id, values) ->
    models = @state.models
    models[meta_key_id].values = values
    @setState({models: models})



  submit: (actionType) ->

    @setState(saving: true, systemError: false)
    serialized = @refs.form.serialize()
    xhr(
      {
        method: 'PUT'
        url: @_actionUrl()
        body: serialized
        headers: {
          'Accept': 'application/json'
          'Content-type': 'application/x-www-form-urlencoded'
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, body) =>

        if err
          window.scrollTo(0, 0)
          @setState(saving: false, systemError: 'Connection error. Please try again.') if @isMounted()
          return

        try
          data = JSON.parse(body)
        catch error
          window.scrollTo(0, 0)
          @setState(saving: false, systemError: 'System error. Cannot parse server answer. Please try again.') if @isMounted()
          return

        if res.statusCode == 400
          errors = f.presence(f.get(data, 'errors')) or {}
          if not f.present(errors)
            window.scrollTo(0, 0)
            @setState(saving: false, systemError: 'System error. Cannot read server errors. Please try again.') if @isMounted()
          else
            window.scrollTo(0, 0)
            @setState(saving: false) if @isMounted()
        else
          forward_url = data['forward_url']
          if not forward_url
            window.scrollTo(0, 0)
            @setState(saving: false, systemError: 'Cannot read forward url. Please try again.') if @isMounted()
          else
            window.location = forward_url
    )

  # NOTE: just to be save, block *implicit* form submits
  # (should normally not be triggered when button[type=button] is used.)
  _onImplicitSumbit: (event) -> event.preventDefault()

  _onExplicitSubmit: (event) ->
    event.preventDefault()
    @submit(event.target.value)
    return false


  _context_keys: (context_id) ->
    meta_meta_data = @props.get.meta_meta_data
    f.map meta_meta_data.context_key_ids_by_context_id[context_id], (context_key_id) ->
      meta_meta_data.context_key_by_context_key_id[context_key_id]


  _toggleBundle: (bundleId) ->
    current = @state.bundleState[bundleId]
    next = not current
    @setState(bundleState: f.set(@state.bundleState, bundleId, next))


  _batchConflict: (context_key_id) ->
    meta_meta_data = @props.get.meta_meta_data
    contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]
    meta_key_id = contextKey.meta_key_id
    batchConflict = @state.batchDiff[meta_key_id]
    if batchConflict
      not batchConflict.all_equal
    else
      false

  _editByVocabButton: (get) ->
    editByVocabTxt = t('media_entry_meta_data_edit_by_vocab_btn')
    editByVocabUrl = unless @props.batch
      get.resource.url + '/meta_data/edit'
    else
      plural = if get.resource_type == 'collection' then 'sets' else 'entries'
      setUrlParams('/' + plural + '/batch_meta_data_edit',
        id: f.map(get.batch_entries, 'uuid'),
        return_to: get.return_to)

    <Button href={editByVocabUrl}>
      <Icon i={'arrow-down'}/> {editByVocabTxt}
    </Button>


  _title: (batchType, get) ->
    title = null
    if @props.batch

      pre_title = t('meta_data_batch_title_pre')
      post_title =
        if batchType == 'MediaEntry'
          t('meta_data_batch_title_post_media_entries')
        else
          t('meta_data_batch_title_post_collections')

      title = pre_title + get.batch_entries.length + post_title
    else
      if get.resource.type == 'Collection'
        title = t('collection_meta_data_header_prefix') + get.resource.title
      else
        title = t('media_entry_meta_data_header_prefix') + get.resource.title
    return title

  _disableSave: (published) ->
    # disableSave = (@state.saving or not @_changesForAll() or (@_validityForAll() == 'invalid' and @props.get.published)) and @state.mounted == true
    disableSave = (@state.saving or (validation._validityForAll(
      @props.get.meta_meta_data, @state.models) == 'invalid' and published)) and @state.mounted == true

  _disablePublish: () ->
    disablePublish = (@state.saving or validation._validityForAll(@props.get.meta_meta_data, @state.models) != 'valid')

  _showNoContextDefinedIfNeeded: () ->
    <div className="ui-alerts">
      <div className="ui-alert warning">
        There are no contexts defined. Please configure them in the admin tool.
      </div>
    </div>



  _namePrefix: (resource, batch, batch_resource_type) ->
    if batch
      batch_resource_type + "[meta_data]"
    else
      "#{f.snakeCase(resource.type)}[meta_data]"


  _atLeastOnePublished: (single_published, batch, batch_entries) ->
    if @props.batch
      published = false
      f.each batch_entries, (entry) ->
        published = true if entry.published
    else
      published = single_published
    return published


  render: ({get, authToken, batchType} = @props) ->

    # First make sure that you do not get a system error page when you have no context configured.
    if get.meta_meta_data.meta_data_edit_context_ids.length == 0
      return @_showNoContextDefinedIfNeeded()

    currentContextId = @state.currentContextId
    if currentContextId
      currentContext = get.meta_meta_data.contexts_by_context_id[currentContextId]

    name = @_namePrefix(get.resource, @props.batch, get.resource_type)

    published = @_atLeastOnePublished(get.published, @props.batch, get.batch_entries)


    bundled_context_keys = grouping._group_keys({ keys_to_check: @_context_keys(currentContextId), inter_result: [] })

    <PageContent>
      <PageContentHeader icon='pen' title={@_title(batchType, get)}>
        {@_editByVocabButton(get)}
      </PageContentHeader>

      {if @props.batch
        <ResourcesBatchBox resources={get.resources.resources} authToken={authToken} />
      }


      {
        Renderer._renderTabs(@props.get.meta_meta_data, @props.batch, @props.get.batch_entries,
          @props.get.return_to, @props.get.url, @_onTabClick, currentContextId)
      }
      <TabContent>

        <RailsForm ref='form'
          name='resource_meta_data' action={@_actionUrl()}
          onSubmit={@_onImplicitSumbit}
          method='put' authToken={authToken}>

          <input type='hidden' name='return_to' value={@props.get.return_to} />


          <div className="ui-container phl ptl">

            {
              unless @props.batch
                Renderer._renderThumbnail(@props.get.resource)
            }

            <div className="app-body-content table-cell ui-container table-substance ui-container">
              <div className={if true then 'active' else 'active tab-pane'}>

                {if @state.systemError
                  <div className="ui-alerts" style={marginBottom: '10px'}>
                    <div className="error ui-alert">
                      {@state.systemError}
                    </div>
                  </div>
                }

                {if @state.errors and f.keys(@state.errors).length > 0
                  <div className="ui-alerts" style={marginBottom: '10px'}>
                    <div className="error ui-alert">
                      {t('resource_meta_data_has_validation_errors')}
                    </div>
                  </div>
                }

                <div className='form-body'>
                  {
                    f.map get.batch_entries, (entry) ->
                      <input key={entry.uuid} type='hidden' name='batch_resource_meta_data[id][]' value={entry.uuid} />
                  }

                  {
                    Renderer._renderContext(currentContextId, bundled_context_keys, get.meta_data, get.meta_meta_data, published, name,
                      @props.batch, @state.models, @state.errors, @_batchConflict, @_onChangeForm, @state.bundleState, @_toggleBundle)
                  }

                  {
                    Renderer._renderHiddenKeys(@props.get.meta_meta_data, currentContext.uuid, @props.get.meta_data, @props.batch, @state.models, name)
                  }
                </div>



              </div>
            </div>


            {
              if @props.batch
                <BatchHintBox />

            }
          </div>


          <div className="ui-actions phl pbl mtl">
            <a className="link weak"
              href={get.return_to || get.resource.url}>{' ' + t('meta_data_form_cancel') + ' '}</a>
            <button className="primary-button large"
              type={if @state.mounted then 'button' else 'submit'} name='actionType' value='save'
              onClick={@_onExplicitSubmit}
              disabled={@_disableSave(published)}>{t('meta_data_form_save')}</button>
          </div>


        </RailsForm>
      </TabContent>
    </PageContent>
