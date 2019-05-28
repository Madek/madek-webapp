React = require('react')
f = require('active-lodash')
t = require('../../../lib/i18n-translate.js')
cx = require('classnames')
InputMetaDatum = require('../InputMetaDatum.cjsx')
MetaKeyFormLabel = require('../../lib/forms/form-label.cjsx')
metadataEditValidation = require('../../../lib/metadata-edit-validation.coffee')
metadataEditGrouping = require('../../../lib/metadata-edit-grouping.coffee')
Picture = require('../../ui-components/Picture.cjsx')
ResourceIcon = require('../../ui-components/ResourceIcon.cjsx')
Tabs = require('../../views/Tabs.cjsx')
Tab = require('../../views/Tab.cjsx')
Icon = require('../../ui-components/Icon.cjsx')
Link = require('../../ui-components/Link.cjsx')
TagCloud = require('../../ui-components/TagCloud.cjsx')
setUrlParams = require('../../../lib/set-params-for-url.coffee')
VocabTitleLink = require('../../ui-components/VocabTitleLink.cjsx')
grouping = require('../../../lib/metadata-edit-grouping.coffee')
labelize = require('../../../lib/labelize').default

module.exports = {

  _renderValueFromWorkflowCommonSettings: (workflow, meta_key_id) ->
    md = f.find(workflow.common_settings.meta_data, (md) -> md.meta_key.uuid is meta_key_id)

    value = if f.has(md.value, '0.string')
      md.value[0].string
    else
      <TagCloud
        mod='person'
        mods='small'
        list={labelize(md.value)} />

    workflowLink = <Link href={workflow.actions.edit.url} mods='strong'>{workflow.name}</Link>
    info = <span style={{fontStyle: 'italic'}}>
      This value is managed by workflow "{workflowLink}"
    </span>
    arrowStyle =
      fontSize: '0.75em'
      position: 'relative'
      top: '-2px'

    <div className='form-item' style={{paddingTop: '5px'}}>
      <div>{value or 'not set'}</div>
      <span style={arrowStyle}>&#11153;</span> {info}
    </div>


  _renderValueByContext: (onChange, name, subForms, metaKey, batch, model, workflow) ->
    meta_key_id = metaKey.uuid

    if batch
      name += "[#{meta_key_id}][values][]"
    else
      name += "[#{meta_key_id}][]"

    input = (
      <InputMetaDatum id={meta_key_id}
        model={model}
        name={name} onChange={onChange}
        subForms={subForms}
        metaKey={metaKey}
      />
    )

    if workflow? and f.includes(f.map(workflow.common_settings.meta_data, 'meta_key.uuid'), meta_key_id)
      @_renderValueFromWorkflowCommonSettings(workflow, meta_key_id)
    else if batch
      style = {marginRight: '200px', marginLeft: '200px'}
      <div style={style}>
        {input}
      </div>
    else
      input


  _renderLabelByContext: (meta_meta_data, context_key_id) ->

    contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]

    meta_key_id = contextKey.meta_key_id
    mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]

    <MetaKeyFormLabel metaKey={meta_meta_data.meta_key_by_meta_key_id[meta_key_id]}
      contextKey={contextKey}
      mandatory={mandatory} />


  _renderLabelByVocabularies: (meta_meta_data, meta_key_id) ->

    mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]

    <MetaKeyFormLabel metaKey={meta_meta_data.meta_key_by_meta_key_id[meta_key_id]}
      contextKey={null}
      mandatory={mandatory} />


  _renderBatchDropdown: (meta_meta_data, meta_key_id, name, model, onChangeBatchAction) ->

    mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]
    return null if mandatory


    style = {float: 'right'}

    _onChange = (event) ->
      event.preventDefault()
      onChangeBatchAction(meta_key_id, event.target.value)

    name += "[#{meta_key_id}][batch_action]"


    <div style={style}>
      <select name={name} value={model.batchAction} onChange={_onChange}>
        <option value='none'>...</option>
        <option value='remove'>{t('meta_data_batch_action_remove_meta_data')}</option>
      </select>
    </div>



  _renderItemByContext2: (meta_meta_data, workflow, published, name, context_key_id, subForms, rowed, batch, model, batchConflict, errors, _onChangeForm) ->

    contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]
    meta_key_id = contextKey.meta_key_id
    metaKey = meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
    mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]
    error = errors[meta_key_id]
    validErr = published and mandatory and (not metadataEditValidation._validModel(model)) and (not batch)
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
      {@_renderLabelByContext(meta_meta_data, context_key_id)}
      {@_renderBatchDropdown(meta_meta_data, meta_key_id, name, model, _onChangeForm.onChangeBatchAction) if batch}
      {@_renderValueByContext(((values) -> _onChangeForm.onValue(meta_key_id, values)), name, subForms, metaKey, batch, model, workflow)}
    </fieldset>


  _renderItemByVocabularies2: (meta_meta_data, workflow, published, name, meta_key_id, subForms, rowed, batch, model, batchConflict, errors, _onChangeForm) ->

    metaKey = meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
    mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]
    error = errors[meta_key_id]
    validErr = published and mandatory and not metadataEditValidation._validModel(model)
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
      {@_renderLabelByVocabularies(meta_meta_data, meta_key_id)}
      {@_renderBatchDropdown(meta_meta_data, meta_key_id, name, model, _onChangeForm.onChangeBatchAction) if batch}
      {@_renderValueByContext(((values) -> _onChangeForm.onValue(meta_key_id, values)), name, subForms, metaKey, batch, model, workflow)}
    </fieldset>


  _renderHiddenKeysByContext: (meta_meta_data, currentContextId, batch, models, name) ->
    meta_key_ids_in_current_context =
      f.map meta_meta_data.context_key_ids_by_context_id[currentContextId], (context_key_id) ->
        meta_key_id = meta_meta_data.meta_key_id_by_context_key_id[context_key_id]

    all_meta_key_ids = f.keys(meta_meta_data.meta_key_by_meta_key_id)

    hidden_meta_key_ids = f.select(all_meta_key_ids, (meta_key_id) ->
      not (f.includes meta_key_ids_in_current_context, meta_key_id)
    )

    f.map hidden_meta_key_ids, (meta_key_id) =>
      model = models[meta_key_id]
      metaKey = meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
      <div style={{display: 'none'}} key={meta_key_id}>
        {@_renderBatchDropdown(meta_meta_data, meta_key_id, name, model, () -> ) if batch}
        {@_renderValueByContext((() -> ), name, null, metaKey, batch, model)}
      </div>


  _bundleHasOnlyOneKey: (bundle) ->
    return bundle.type == 'single' or (bundle.type == 'block' and f.size(bundle.content) == 0)

  _bundleGetTheOnlyContent: (bundle) ->
    if bundle.type == 'single' then bundle.content else bundle.mainKey


  _renderSubForms: (bundle, bundleState, _toggleBundle, isInvalid, children) ->

    style = {
      display: (if (bundleState[bundle.bundle] or isInvalid) then 'block' else 'none')
      marginTop: '10px'
      marginBottom: '20px'
    }

    subForms = [
      <a key='sub-form-link' className={cx('button small form-item-extension-toggle mtm',
        {'active': isInvalid })}
        onClick={((() -> _toggleBundle(bundle.bundle)) if not isInvalid)}>
        <i className="icon-plus-small"></i>   {t('meta_data_edit_more_data')}
      </a>
      ,
      <div key='sub-form-values' style={style}
        className="ui-container pam ui-container bordered rounded form-item-extension hidden"
        key={'block_' + bundle.bundle}>
        {children}
      </div>
    ]


  _context_keys: (meta_meta_data, context_id) ->
    f.map meta_meta_data.context_key_ids_by_context_id[context_id], (context_key_id) ->
      meta_meta_data.context_key_by_context_key_id[context_key_id]


  _renderByContext: (context_id, meta_meta_data, workflow, published, name,
    batch, models, errors, _batchConflictByContextKey, _onChangeForm, bundleState, _toggleBundle) ->

    bundled_context_keys = grouping._group_context_keys(@_context_keys(meta_meta_data, context_id))

    _renderItemByContextKeyId = (context_key_id, subForms, rowed, batchConflict) =>

      contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]

      @_renderItemByContext2(meta_meta_data, workflow, published, name, context_key_id, subForms, rowed,
        batch, models[contextKey.meta_key_id], _batchConflictByContextKey(context_key_id), errors, _onChangeForm)


    f.map(
      bundled_context_keys,
      (bundle) =>
        if @_bundleHasOnlyOneKey(bundle)
          context_key_id = @_bundleGetTheOnlyContent(bundle).uuid
          _renderItemByContextKeyId(context_key_id, null, false)
        else
          subFormIsInvalid = metadataEditValidation._validityForMetaKeyIds(
            meta_meta_data, models, f.map(bundle.content, 'meta_key_id')) == 'invalid'

          children = f.map(
            bundle.content,
            (entry) ->
              _renderItemByContextKeyId(entry.uuid, null, true)
          )

          subForms = @_renderSubForms(bundle, bundleState, _toggleBundle, subFormIsInvalid, children)

          context_key_id = bundle.mainKey.uuid
          _renderItemByContextKeyId(context_key_id, subForms, false)
    )



  _sortedVocabularies: (meta_meta_data) ->
    f.sortBy(
      f.values(
        meta_meta_data.vocabularies_by_vocabulary_id
      ),
      (vocabulary) ->
        if vocabulary.uuid == 'madek_core'
          - 1
        else
          vocabulary.position
    )

  _sortedMetadata: (meta_meta_data, meta_data, vocabulary) ->
    meta_key_ids = meta_meta_data.meta_key_ids_by_vocabulary_id[vocabulary.uuid]

    meta_keys = f.map(
      meta_key_ids,
      (meta_key_id) ->
        meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
    )

    sorted = f.sortBy(meta_keys, 'position')

    f.map(
      sorted,
      (meta_key) ->
        meta_data.meta_datum_by_meta_key_id[meta_key.uuid]
    )





  _renderByVocabularies: (meta_data, meta_meta_data, workflow, published, name,
    batch, models, errors, _batchConflictByMetaKey, _onChangeForm, bundleState, _toggleBundle) ->


    sorted_vocabs = @_sortedVocabularies(meta_meta_data)

    f.map(

      sorted_vocabs,

      (vocabulary) =>

        vocabMetaData = @_sortedMetadata(meta_meta_data, meta_data, vocabulary)

        bundled_meta_data = grouping._group_meta_data(vocabMetaData)

        _renderItemByMetaKeyId = (meta_key_id, subForms, rowed) =>
          @_renderItemByVocabularies2(meta_meta_data, workflow, published, name, meta_key_id, subForms, rowed,
            batch, models[meta_key_id], _batchConflictByMetaKey(meta_key_id), errors, _onChangeForm)


        <div className='mbl' key={vocabulary.uuid}>
          <div className='ui-container pas'>
            <VocabTitleLink id={vocabulary.uuid} text={vocabulary.label}
              separated={true} href={vocabulary.url} />
          </div>
          {
            f.map(
              bundled_meta_data,
              (bundle) =>
                if @_bundleHasOnlyOneKey(bundle)
                  meta_key_id = @_bundleGetTheOnlyContent(bundle).meta_key_id
                  _renderItemByMetaKeyId(meta_key_id, null, false)
                else
                  subFormIsInvalid = metadataEditValidation._validityForMetaKeyIds(
                    meta_meta_data, models, f.map(bundle.content, 'meta_key_id')) == 'invalid'

                  children = f.map(
                    bundle.content,
                    (entry) ->
                      _renderItemByMetaKeyId(entry.meta_key_id, null, true)
                  )

                  subForms = @_renderSubForms(bundle, bundleState, _toggleBundle, subFormIsInvalid, children)

                  meta_key_id = bundle.mainKey.meta_key_id
                  _renderItemByMetaKeyId(meta_key_id, subForms, false)

            )


          }
        </div>

    )


  _renderVocabQuickLinks: (meta_data, meta_meta_data) ->

    <div className='ui-container pas'>
      <div style={{paddingBottom: '30px'}}>
        {
          vocabularies = @_sortedVocabularies(meta_meta_data)
          f.flatten f.map(
            vocabularies
            ,
            (vocabulary, index) =>
              vocabMetaData = @_sortedMetadata(meta_meta_data, meta_data, vocabulary)

              [
                <span className='title-l' key={'href_' + vocabulary.uuid} style={{fontWeight: 'normal'}}>
                  <a href={'#' + vocabulary.uuid}>{vocabulary.label}</a>
                </span>
                ,
                if index != vocabularies.length - 1
                  <span className='title-l' key={'separator_' + vocabulary.uuid} style={{paddingRight: '10px', paddingLeft: '10px', fontWeight: 'normal'}}>|</span>
              ]

          )
        }
      </div>
      <div style={{clear: 'both'}} />
    </div>


  _renderThumbnail: (resource, displayMetaData = true) ->
    src = resource.image_url

    if resource.media_file && resource.media_file.previews
      previews = resource.media_file.previews
      href = f.chain(previews.images).sortBy('width').last().get('url').run()

    alt = ''
    image = if src
      <Picture mods='ui-thumbnail-image' src={src} alt={alt} />
    else
      <ResourceIcon
        thumbnail={true}
        mediaType={resource.media_type}
        type={resource.type} />

    className = if resource.type == 'Collection' then 'media-set ui-thumbnail' else 'image media-entry ui-thumbnail'


    <div className="app-body-sidebar table-cell ui-container table-side">
      <ul className="ui-resources grid">
        <li className="ui-resource mrl">
          <div className={className}>
            <div className="ui-thumbnail-privacy">
              <i className="icon-privacy-private" title={t('contents_privacy_private')}></i>
            </div>
            <div className="ui-thumbnail-image-wrapper">
              {
                if href
                  <div className="ui-has-magnifier">
                    <a href={href} target='_blank'>
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
                    <a href={href} target='_blank' className='ui-magnifier' style={{textDecoration: 'none'}}>
                      <Icon i='magnifier' mods='bright'/>
                    </a>
                  </div>
                else
                  <div className="ui-thumbnail-image-holder">
                    <div className="ui-thumbnail-table-image-holder">
                      <div className="ui-thumbnail-cell-image-holder">
                        <div className="ui-thumbnail-inner-image-holder">
                          {image}
                        </div>
                      </div>
                    </div>
                  </div>
              }
            </div>
            {displayMetaData && (
              <div className="ui-thumbnail-meta">
                <h3 className="ui-thumbnail-meta-title">{resource.title}</h3>
                <h4 className="ui-thumbnail-meta-subtitle">{resource.subtitle}</h4>
              </div>
            )}


          </div>
        </li>
      </ul>
    </div>



  _renderTabs: (meta_meta_data, batch, batch_ids, return_to, url, onTabClick, currentTab, collection_id, resource_type,
                edit_by_context_urls, edit_by_context_fallback_url, batch_edit_by_context_urls, batch_edit_by_context_fallback_url,
                edit_by_vocabularies_url, batch_edit_by_vocabularies_url, batch_edit_all_collection_url) ->
    <Tabs>
      {
        f.map meta_meta_data.meta_data_edit_context_ids, (context_id) ->
          context = meta_meta_data.contexts_by_context_id[context_id]
          tabUrl =
            if batch

              if collection_id
                setUrlParams(batch_edit_all_collection_url,
                  type: resource_type,
                  context_id: context.uuid
                  by_vocabulary: false
                  return_to: return_to)

              else
                url = f.get(batch_edit_by_context_urls, context.uuid, batch_edit_by_context_fallback_url)
                setUrlParams(url,
                  id: batch_ids,
                  return_to: return_to)
            else
              url = f.get(edit_by_context_urls, context.uuid, edit_by_context_fallback_url)
              setUrlParams(url,
                return_to: return_to)

          if not f.isEmpty(meta_meta_data.context_key_ids_by_context_id[context_id])
            nextCurrentTab = {
              byContext: context_id,
              byVocabularies: false
            }

            active = (!currentTab.byVocabularies) && (currentTab.byContext == context.uuid)

            <Tab
              privacyStatus={'public'}
              key={context.uuid}
              iconType={null}
              onClick={f.curry(onTabClick)(nextCurrentTab)}
              href={tabUrl}
              label={context.label}
              active={active} />
      }
      {
        tabUrl =
          if batch

            if collection_id
                setUrlParams(batch_edit_all_collection_url,
                  type: resource_type,
                  context_id: null
                  by_vocabulary: true
                  return_to: return_to)

            else
              setUrlParams(batch_edit_by_vocabularies_url,
                id: batch_ids,
                return_to: return_to)
          else
            setUrlParams(edit_by_vocabularies_url,
              return_to: return_to)

        nextCurrentTab = {
          byContext: null,
          byVocabularies: true
        }

        active = currentTab.byVocabularies

        <Tab
          privacyStatus={'public'}
          key={'byVocabularies'}
          iconType={null}
          onClick={f.curry(onTabClick)(nextCurrentTab)}
          href={tabUrl}
          label={t('meta_data_form_all_data')}
          active={active} />

      }
    </Tabs>


}
