React = require('react')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
cx = require('classnames')
InputMetaDatum = require('../InputMetaDatum.cjsx')
MetaKeyFormLabel = require('../../lib/forms/form-label.cjsx')
metadataEditValidation = require('../../../lib/metadata-edit-validation.coffee')
metadataEditGrouping = require('../../../lib/metadata-edit-grouping.coffee')

module.exports = {

  _renderValue: (meta_key_id, onChange, datum, name, subForms, contextKey, batch, models) ->

    if batch
      name += "[#{meta_key_id}][values][]"
    else
      name += "[#{meta_key_id}][]"

    model = models[meta_key_id]

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


  _renderItem: (meta_data, meta_meta_data, published, name, context_key_id, subForms, rowed, batch, models, batchConflict, errors, _onChangeForm) ->

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
      {@_renderLabel(meta_meta_data, context_key_id)}
      {@_renderValue(meta_key_id, ((values) -> _onChangeForm(meta_key_id, values)), datum, name, subForms, contextKey, batch, models)}
    </fieldset>


  _renderItemOrGroup: (context_id, bundled_context_keys, meta_data, meta_meta_data, published, name,
    batch, models, errors, _batchConflict, _onChangeForm, bundleState, _toggleBundle) ->

    f.flatten f.map(
      bundled_context_keys,
      (bundle) =>
        if bundle.type == 'single' or (bundle.type == 'block' and f.size(bundle.content) == 0)
          context_key_id = if bundle.type == 'single' then bundle.content.uuid else bundle.mainKey.uuid
          @_renderItem(meta_data, meta_meta_data, published, name, context_key_id, null, false,
            batch, models, _batchConflict(context_key_id), errors, _onChangeForm)
        else
          context_key_id = bundle.mainKey.uuid

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
                    @_renderItem(meta_data, meta_meta_data, published, name, entry.uuid, null, true,
                      batch, models, _batchConflict(entry.uuid), errors, _onChangeForm)
                )
              }
            </div>
          ]

          @_renderItem(meta_data, meta_meta_data, published, name, context_key_id, subForms, false,
            batch, models, _batchConflict(context_key_id), errors, _onChangeForm)
    )


}
