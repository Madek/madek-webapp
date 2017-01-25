React = require('react')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
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
setUrlParams = require('../../../lib/set-params-for-url.coffee')

module.exports = {

  _renderValueByContext: (meta_key_id, onChange, datum, name, subForms, contextKey, batch, model) ->

    if batch
      name += "[#{meta_key_id}][values][]"
    else
      name += "[#{meta_key_id}][]"

    newget = f.mapValues datum, (value) ->
      value
    newget.values = model.values

    <InputMetaDatum id={meta_key_id}
      name={name} get={newget} onChange={onChange}
      subForms={subForms}
      contextKey={contextKey}
    />

  _renderValueByVocabularies: (meta_key_id, onChange, datum, name, batch, model) ->
    @_renderValueByContext(meta_key_id, onChange, datum, name, null, null, batch, model)


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

  _renderItemByContext: (meta_data, meta_meta_data, published, name, context_key_id, subForms, rowed, batch, models, batchConflict, errors, _onChangeForm) ->

    contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]
    meta_key_id = contextKey.meta_key_id
    datum = meta_data.meta_datum_by_meta_key_id[meta_key_id]
    model = models[meta_key_id]
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
      {@_renderLabelByContext(meta_meta_data, context_key_id)}
      {@_renderValueByContext(meta_key_id, ((values) -> _onChangeForm(meta_key_id, values)), datum, name, subForms, contextKey, batch, model)}
    </fieldset>


  _renderItemByVocabularies: (meta_data, meta_meta_data, published, name, meta_key_id, rowed, batch, models, batchConflict, errors, _onChangeForm) ->

    datum = meta_data.meta_datum_by_meta_key_id[meta_key_id]
    model = models[meta_key_id]
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
      {@_renderValueByVocabularies(meta_key_id, ((values) -> _onChangeForm(meta_key_id, values)), datum, name, batch, model)}
    </fieldset>


  _renderHiddenKeysByContext: (meta_meta_data, currentContextId, meta_data, batch, models, name) ->
    meta_key_ids_in_current_context =
      f.map meta_meta_data.context_key_ids_by_context_id[currentContextId], (context_key_id) ->
        meta_key_id = meta_meta_data.meta_key_id_by_context_key_id[context_key_id]

    all_meta_key_ids = f.keys(meta_meta_data.meta_key_by_meta_key_id)

    hidden_meta_key_ids = f.select(all_meta_key_ids, (meta_key_id) ->
      not (f.includes meta_key_ids_in_current_context, meta_key_id)
    )

    f.map hidden_meta_key_ids, (meta_key_id) =>
      datum = meta_data.meta_datum_by_meta_key_id[meta_key_id]
      model = models[meta_key_id]
      if datum
        <div style={{display: 'none'}} key={meta_key_id}>
          {@_renderValueByContext(meta_key_id, (() -> ), datum, name, null, null, batch, model)}
        </div>


  _bundleHasOnlyOneKey: (bundle) ->
    return bundle.type == 'single' or (bundle.type == 'block' and f.size(bundle.content) == 0)

  _bundleGetTheOnlyContextKeyId: (bundle) ->
    if bundle.type == 'single' then bundle.content.uuid else bundle.mainKey.uuid


  _renderSubForms: (meta_meta_data, meta_data, models, bundle, bundleState, published, name,
    batch, _batchConflictByContextKey, errors, _onChangeForm, _toggleBundle) ->

    isInvalid = metadataEditValidation._validityForMetaKeyIds(meta_meta_data, models, f.map(bundle.content, 'meta_key_id')) == 'invalid'

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
        {
          f.map(
            bundle.content,
            (entry) =>
              @_renderItemByContext(meta_data, meta_meta_data, published, name, entry.uuid, null, true,
                batch, models, _batchConflictByContextKey(entry.uuid), errors, _onChangeForm)
          )
        }
      </div>
    ]


  _renderByContext: (context_id, bundled_context_keys, meta_data, meta_meta_data, published, name,
    batch, models, errors, _batchConflictByContextKey, _onChangeForm, bundleState, _toggleBundle) ->

    f.flatten f.map(
      bundled_context_keys,
      (bundle) =>
        if @_bundleHasOnlyOneKey(bundle)
          context_key_id = @_bundleGetTheOnlyContextKeyId(bundle)
          @_renderItemByContext(meta_data, meta_meta_data, published, name, context_key_id, null, false,
            batch, models, _batchConflictByContextKey(context_key_id), errors, _onChangeForm)
        else
          context_key_id = bundle.mainKey.uuid

          subForms = @_renderSubForms(meta_meta_data, meta_data, models, bundle, bundleState,
            published, name, batch, _batchConflictByContextKey, errors, _onChangeForm, _toggleBundle)

          @_renderItemByContext(meta_data, meta_meta_data, published, name, context_key_id, subForms, false,
            batch, models, _batchConflictByContextKey(context_key_id), errors, _onChangeForm)
    )

  _renderByVocabularies: (meta_data, meta_meta_data, published, name,
    batch, models, errors, _batchConflictByMetaKey, _onChangeForm, bundleState, _toggleBundle) ->

    f.flatten f.map(
      f.sortBy(meta_data.by_vocabulary, (voc) -> if voc.vocabulary.uuid == 'madek_core' then - 1 else voc.vocabulary.position),
      (vocabularyInfo) =>
        vocabMetaData = f.sortBy(vocabularyInfo.meta_data, 'meta_key.position')
        vocabularyDetails = vocabularyInfo.vocabulary


        <div className='mbl' key={vocabularyDetails.uuid}>
          <div className='ui-container separated pas'>
            <h3 className='title-l'>
              {vocabularyDetails.label + ' '}
              <small>{"(#{vocabularyDetails.uuid})"}</small>
            </h3>
            <p className='paragraph-s'>{vocabularyDetails.description}</p>
          </div>
          {
            f.map(
              vocabMetaData,
              (vocabMetaDatum) =>

                meta_key_id = vocabMetaDatum.meta_key_id
                @_renderItemByVocabularies(meta_data, meta_meta_data, published, name, meta_key_id, false,
                  batch, models, _batchConflictByMetaKey(meta_key_id), errors, _onChangeForm)

            )
          }
        </div>

    )


  _renderThumbnail: (resource) ->
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
              <i className="icon-privacy-private" title="Diese Inhalte sind nur für Sie zugänglich"></i>
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
            <div className="ui-thumbnail-meta">
              <h3 className="ui-thumbnail-meta-title">{resource.title}</h3>
              <h4 className="ui-thumbnail-meta-subtitle">{resource.subtitle}</h4>
            </div>


          </div>
        </li>
      </ul>
    </div>



  _renderTabs: (meta_meta_data, batch, batch_entries, return_to, url, onTabClick, currentTab) ->
    <Tabs>
      {
        f.map meta_meta_data.meta_data_edit_context_ids, (context_id) ->
          context = meta_meta_data.contexts_by_context_id[context_id]
          tabUrl =
            if batch
              setUrlParams('/entries/batch_edit_meta_data_by_context/' + context.uuid,
                id: f.map(batch_entries, 'uuid'),
                return_to: return_to)
            else
              setUrlParams(url + '/meta_data/edit_context/' + context.uuid,
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
            setUrlParams('/entries/batch_edit_meta_data_by_vocabularies',
              id: f.map(batch_entries, 'uuid'),
              return_to: return_to)
          else
            setUrlParams(url + '/meta_data/edit/by_vocabularies',
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
          label={'Alle Daten'}
          active={active} />

      }
    </Tabs>


}
