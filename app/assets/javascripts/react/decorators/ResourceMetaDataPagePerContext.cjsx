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
    automaticPublish = @_validityForAll() == 'valid' and @state.mounted == true and not @props.get.published
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



  _modelForMetaKey: (meta_key) ->
    {
      multiple: not (meta_key.value_type == "MetaDatum::Text" or meta_key.value_type == "MetaDatum::TextDate")
      meta_key: meta_key
      values: []
      originalValues: []
    }

  componentDidMount: () ->
    @setState({mounted: true})


  componentWillMount: () ->

    currentContextId = @props.get.context_id
    if currentContextId == null
      currentContextId = @props.get.meta_meta_data.meta_data_edit_context_ids[0]

    @setState({currentContextId: currentContextId})

    models = f.mapValues @props.get.meta_meta_data.meta_key_by_meta_key_id, (meta_key) =>
      @_modelForMetaKey(meta_key)

    f.each @props.get.meta_data.existing_meta_data_by_meta_key_id, (data, meta_key_id) ->
      models[meta_key_id].values = data.values

    f.each models, (model) ->
      model.originalValues = f.map model.values, (value) ->
        value

    if @props.batch

      diff = batchDiff(
        @props.get.meta_meta_data.meta_key_by_meta_key_id,
        @props.get.batch_entries)

      @setState({
        batchDiff: diff
      })

      f.each models, (model, meta_key_id) ->
        unless diff[meta_key_id].all_equal
          model.originalValues = []
          model.values = []


    @setState({models: models})


  _validModel: (model) ->
    if model.multiple
      model.values.length > 0
    else
      if model.values[0]
        model.values[0].trim().length > 0
      else
        false

  _meta_key_ids_by_context_id: (context_id) ->
    res = f.map(
      @props.get.meta_meta_data.context_key_ids_by_context_id[context_id],
      (context_key_id) =>
        @props.get.meta_meta_data.meta_key_id_by_context_key_id[context_key_id]
    )
    res

  _validityForAll: () ->
    mandatory_meta_key_ids = f.keys @props.get.meta_meta_data.mandatory_by_meta_key_id
    @_validityForMandatoryMetaKeyIds(mandatory_meta_key_ids)

  _validityForMetaKeyIds: (meta_key_ids) ->
    mandatory_meta_key_ids = f.keys(@props.get.meta_meta_data.mandatory_by_meta_key_id)
    reduced_mandatories = f.filter(meta_key_ids, (meta_key_id) ->
      f.include(mandatory_meta_key_ids, meta_key_id))
    @_validityForMandatoryMetaKeyIds(reduced_mandatories)


  _validityForMandatoryMetaKeyIds: (mandatory_meta_key_ids) ->
    hasMandatory = false
    hasInvalid = false
    f.each mandatory_meta_key_ids, (meta_key_id) =>

      hasMandatory = true
      model = @state.models[meta_key_id]
      # Note: The model can be unknown, because you can get more mandatory
      # fields than keys (some are not visible for the user).
      if model and not @_validModel(model)
        hasInvalid = true

    if not hasMandatory
      'not_mandatory'
    else if hasInvalid
      'invalid'
    else
      'valid'

  _validityForContext: (context_id) ->
    meta_key_ids = @_meta_key_ids_by_context_id(context_id)
    @_validityForMetaKeyIds(meta_key_ids)

  _changesPerContext: (context_id) ->
    hasChanges = false
    f.each @state.models, (model, meta_key_id) =>
      if context_id and (f.includes(@_meta_key_ids_by_context_id(context_id), meta_key_id)) or not context_id
        unless model.multiple == false and model.originalValues.length == 0 and model.values.length == 1 and model.values[0].trim() == ''

          # Note: New keywords have no uuid yet. Fortunately new keywords always mean that the length is different.
          if not @_equalUnordered(model.values, model.originalValues, model.multiple)
            hasChanges = true

    hasChanges


  _equalUnordered: (arr1, arr2, checkUuid) ->

    if arr1.length != arr2.length
      return false

    equal = true
    f.each(arr1, (value1) ->

      found = false
      f.each(arr2, (value2) ->
        if checkUuid == true
          if(value1.uuid == value2.uuid)
            found = true
        else
          if value1 == value2
            found = true

      )

      if found == false
        equal = false
    )

    return equal





  _changesForAll: () ->
    @_changesPerContext(null)


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


  # NOTE: Temporary solution for "bundling" of keys. comes from instance config.
  _prefixesForBundle: () -> APP_CONFIG.bundle_context_keys || []

  _find_exact_in_bundle: (meta_key_id) ->
    f.find @_prefixesForBundle(), (prefix) ->
      meta_key_id == prefix.group


  _diff_keys: (a, b) ->

    contains_key = (arr, key_id) ->
      f.find arr, (ai) ->
        ai.uuid == key_id

    f.reject a, (ai) ->
      contains_key(b, ai.uuid)


  _reject_followups: (keys_to_check, bundle_key) ->

    first_not_matching = f.findIndex keys_to_check, (key) ->
      not f.startsWith(key.meta_key_id, bundle_key.prefix)

    return [] if first_not_matching < 0

    f.slice keys_to_check, first_not_matching


  _group_keys: ({keys_to_check, inter_result}) ->

    if f.isEmpty(keys_to_check)
      inter_result
    else

      bundle_key = @_find_exact_in_bundle(f.first(keys_to_check).meta_key_id)

      rec_keys_to_check =
        if bundle_key
          @_reject_followups(f.slice(keys_to_check, 1), bundle_key)
        else
          f.slice(keys_to_check, 1)

      rec_inter_result =
        if bundle_key
          {
            type: 'block'
            bundle: bundle_key.group
            mainKey: f.first(@_diff_keys(keys_to_check, rec_keys_to_check))
            content: f.slice(@_diff_keys(keys_to_check, rec_keys_to_check), 1)
          }
        else
          {
            type: 'single'
            content: f.first(keys_to_check)
          }


      @_group_keys(
        {
          keys_to_check: rec_keys_to_check,
          inter_result: inter_result.concat([rec_inter_result])
        }
      )

  _context_keys: (context_id) ->
    meta_meta_data = @props.get.meta_meta_data
    f.map meta_meta_data.context_key_ids_by_context_id[context_id], (context_key_id) ->
      meta_meta_data.context_key_by_context_key_id[context_key_id]


  _toggleBundle: (bundleId) ->
    current = @state.bundleState[bundleId]
    next = not current
    @setState(bundleState: f.set(@state.bundleState, bundleId, next))


  _batchConflict: (meta_key_id) ->

    batchConflict = @state.batchDiff[meta_key_id]
    if batchConflict
      not batchConflict.all_equal
    else
      false

  _renderValue: (meta_key_id, hidden, onChange, datum, name, subForms, contextKey) ->

    if @props.batch
      name += "[#{meta_key_id}][values][]"
    else
      name += "[#{meta_key_id}][]"

    model = @state.models[meta_key_id]

    newget = f.mapValues datum, (value) ->
      value
    newget.values = model.values

    <InputMetaDatum id={meta_key_id}
      name={name} get={newget} onChange={onChange}
      subForms={subForms}
      contextKey={contextKey}
    />

  _renderLabel: (meta_meta_data, context_key_id) ->

    contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]

    meta_key_id = contextKey.meta_key_id
    mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]

    <MetaKeyFormLabel metaKey={meta_meta_data.meta_key_by_meta_key_id[meta_key_id]}
      contextKey={contextKey}
      mandatory={mandatory} />


  _renderItem: (meta_data, meta_meta_data, published, name, context_key_id, subForms, rowed) ->

    contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]
    meta_key_id = contextKey.meta_key_id
    datum = meta_data.meta_datum_by_meta_key_id[meta_key_id]
    batchConflict = @_batchConflict(meta_key_id)
    model = @state.models[meta_key_id]
    mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]
    error = @state.errors[meta_key_id]
    validErr = published and mandatory and not @_validModel(model)
    className = cx('ui-form-group prh', {'columned': not rowed}, {'rowed': rowed},
      {'error': (error or validErr) and not batchConflict}, {'highlight': batchConflict})

    <fieldset className={className} key={meta_key_id}>
      {if error
        <div className="ui-alerts" style={marginBottom: '10px'}>
          <div className="error ui-alert">
            {error}
          </div>
        </div>
      }
      {@_renderLabel(meta_meta_data, context_key_id)}
      {@_renderValue(meta_key_id, false, ((values) => @_onChangeForm(meta_key_id, values)), datum, name, subForms, contextKey)}
    </fieldset>


  _renderItemOrGroup: (context_id, bundled_context_keys, meta_data, meta_meta_data, published, name) ->

    f.flatten f.map(
      bundled_context_keys,
      (bundle) =>
        if bundle.type == 'single' or (bundle.type == 'block' and f.size(bundle.content) == 0)
          context_key_id = if bundle.type == 'single' then bundle.content.uuid else bundle.mainKey.uuid
          @_renderItem(meta_data, meta_meta_data, published, name, context_key_id, null, false)
        else
          context_key_id = bundle.mainKey.uuid

          isInvalid = @_validityForMetaKeyIds(f.map(bundle.content, 'meta_key_id')) == 'invalid'

          style = {
            display: (if (@state.bundleState[bundle.bundle] or isInvalid) then 'block' else 'none')
            marginTop: '10px'
            marginBottom: '20px'
          }

          subForms = [
            <a key='sub-form-link' className={cx('button small form-item-extension-toggle mtm',
              {'active': isInvalid })}
              onClick={((() => @_toggleBundle(bundle.bundle)) if not isInvalid)}>
              <i className="icon-plus-small"></i>   {t('meta_data_edit_more_data')}
            </a>
            ,
            <div key='sub-form-values' style={style}
              className="ui-container pam ui-container bordered rounded form-item-extension hidden"
              key={'block_' + bundle.bundle}>
              {
                f.map(
                  bundle.content,
                  (entry) =>
                    @_renderItem(meta_data, meta_meta_data, published, name, entry.uuid, null, true)
                )
              }
            </div>
          ]

          @_renderItem(meta_data, meta_meta_data, published, name, context_key_id, subForms, false)
    )

  render: ({get, authToken, batchType} = @props) ->

    if get.meta_meta_data.meta_data_edit_context_ids.length == 0
      # First make sure that you do not get a system error page when you have no context configured.
      return (
        <div className="ui-alerts">
          <div className="ui-alert warning">
            There are no contexts defined. Please configure them in the admin tool.
          </div>
        </div>
      )

    currentContextId = @state.currentContextId

    if currentContextId
      currentContext = get.meta_meta_data.contexts_by_context_id[currentContextId]

    className = null
    unless @props.batch
      className = if get.resource.type == 'Collection' then 'media-set ui-thumbnail' else 'image media-entry ui-thumbnail'

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

    editByVocabTxt = t('media_entry_meta_data_edit_by_vocab_btn')
    editByVocabUrl = unless @props.batch
      get.resource.url + '/meta_data/edit'
    else
      plural = if get.resource_type == 'collection' then 'sets' else 'entries'
      setUrlParams('/' + plural + '/batch_meta_data_edit',
        id: f.map(get.batch_entries, 'uuid'),
        return_to: get.return_to)

    name = if @props.batch
      get.resource_type + "[meta_data]"
    else
      "#{f.snakeCase(get.resource.type)}[meta_data]"

    meta_data = get.meta_data

    submitButtonType = if @state.mounted then 'button' else 'submit'

    # disableSave = (@state.saving or not @_changesForAll() or (@_validityForAll() == 'invalid' and @props.get.published)) and @state.mounted == true
    disableSave = (@state.saving or (@_validityForAll() == 'invalid' and @props.get.published)) and @state.mounted == true

    disablePublish = (@state.saving or @_validityForAll() != 'valid')
    showPublish = not @props.get.published and @state.mounted == true

    showPublish = false

    published = get.published
    if @props.batch
      published = false
      f.each get.batch_entries, (entry) ->
        published = true if entry.published

    cancelUrl =
      if @props.batch
        if not get.return_to
          throw new Error('No return_to given for batch edit (ResourceMetaDataPagePerContext).')
        get.return_to
      else
        get.url

    bundled_context_keys = @_group_keys({ keys_to_check: @_context_keys(currentContextId), inter_result: [] })

    <PageContent>
      <PageContentHeader icon='pen' title={title}>
        <Button href={editByVocabUrl}>
          <Icon i={'arrow-down'}/> {editByVocabTxt}
        </Button>
      </PageContentHeader>

      {if @props.batch
        <ResourcesBatchBox resources={get.resources.resources} authToken={authToken} />
      }

      <Tabs>
        {f.map get.meta_meta_data.meta_data_edit_context_ids, (context_id) =>
          context = get.meta_meta_data.contexts_by_context_id[context_id]
          tabUrl =
            if @props.batch
              setUrlParams('/entries/batch_edit_context_meta_data/' + context.uuid,
                id: f.map(get.batch_entries, 'uuid'),
                return_to: get.return_to)
            else
              setUrlParams(get.url + '/meta_data/edit_context/' + context.uuid,
                return_to: get.return_to)

          if not f.isEmpty(get.meta_meta_data.context_key_ids_by_context_id[context_id])
            <Tab
              hasChanges={@_changesPerContext(context_id)}
              validity={@_validityForContext(context_id)}
              privacyStatus={'public'}
              key={context.uuid}
              iconType={null}
              onClick={@_onTabClick.bind(@, context.uuid)}
              href={tabUrl}
              label={context.label}
              active={context.uuid == currentContextId} />
        }
      </Tabs>
      <TabContent>

        <RailsForm ref='form'
          name='resource_meta_data' action={@_actionUrl()}
          onSubmit={@_onImplicitSumbit}
          method='put' authToken={authToken}>

          <input type='hidden' name='return_to' value={@props.get.return_to} />


          <div className="ui-container phl ptl">

            {
              unless @props.batch


                src = get.resource.image_url
                alt = ''
                image = if src
                  <Picture mods='ui-thumbnail-image' src={src} alt={alt} />
                else
                  <ResourceIcon
                    thumbnail={true}
                    mediaType={get.resource.media_type}
                    type={get.resource.type} />

                <div className="app-body-sidebar table-cell ui-container table-side">
                  <ul className="ui-resources grid">
                    <li className="ui-resource mrl">


                      <div className={className}>
                        <div className="ui-thumbnail-privacy">
                          <i className="icon-privacy-private" title="Diese Inhalte sind nur für Sie zugänglich"></i>
                        </div>
                        <div className="ui-thumbnail-image-wrapper">
                          <div className="ui-has-magnifier">
                            <a href={src} target='_blank'>
                              <div className="ui-thumbnail-image-holder">
                                <div className="ui-thumbnail-table-image-holder">
                                  <div className="ui-thumbnail-cell-image-holder">
                                    <div className="ui-thumbnail-inner-image-holder">
                                      {image}
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </a>
                            <a href={src} target='_blank' className='ui-magnifier' style={{textDecoration: 'none'}}>
                              <Icon i='magnifier' mods='bright'/>
                            </a>
                          </div>
                        </div>
                        <div className="ui-thumbnail-meta">
                          <h3 className="ui-thumbnail-meta-title">{get.resource.title}</h3>
                          <h4 className="ui-thumbnail-meta-subtitle">{get.resource.subtitle}</h4>
                        </div>


                      </div>
                    </li>
                  </ul>
                </div>
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
                    @_renderItemOrGroup(currentContextId, bundled_context_keys, get.meta_data, get.meta_meta_data, published, name)
                  }


                  {

                    meta_key_ids_in_current_context =
                      f.map get.meta_meta_data.context_key_ids_by_context_id[currentContext.uuid], (context_key_id) ->
                        meta_key_id = get.meta_meta_data.meta_key_id_by_context_key_id[context_key_id]

                    all_meta_key_ids = f.keys(get.meta_meta_data.meta_key_by_meta_key_id)

                    hidden_meta_key_ids = f.select(all_meta_key_ids, (meta_key_id) ->
                      not (f.includes meta_key_ids_in_current_context, meta_key_id)
                    )

                    f.map hidden_meta_key_ids, (meta_key_id) =>
                      datum = get.meta_data.meta_datum_by_meta_key_id[meta_key_id]
                      if datum

                        <div style={{display: 'none'}} key={meta_key_id} >
                          {@_renderValue(meta_key_id, true, (() -> ), datum, name, null)}
                        </div>

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
              type={submitButtonType} name='actionType' value='save'
              onClick={@_onExplicitSubmit}
              disabled={disableSave}>{t('meta_data_form_save')}</button>
            {
              if showPublish
                <button className='primary-button large'
                  type={submitButtonType} name='actionType' value='publish'
                  onClick={@_onExplicitSubmit}
                  disabled={disablePublish}>{t('meta_data_form_publish')}</button>
            }
          </div>


        </RailsForm>
      </TabContent>
    </PageContent>
