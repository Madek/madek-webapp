/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate.js'
import cx from 'classnames'
import InputMetaDatum from '../InputMetaDatum.jsx'
import MetaKeyFormLabel from '../../lib/forms/form-label.jsx'
import metadataEditValidation from '../../../lib/metadata-edit-validation.js'
import Picture from '../../ui-components/Picture.jsx'
import ResourceIcon from '../../ui-components/ResourceIcon.jsx'
import Tabs from '../../views/Tabs.jsx'
import Tab from '../../views/Tab.jsx'
import Icon from '../../ui-components/Icon.jsx'
import Link from '../../ui-components/Link.jsx'
import TagCloud from '../../ui-components/TagCloud.jsx'
import setUrlParams from '../../../lib/set-params-for-url.js'
import VocabTitleLink from '../../ui-components/VocabTitleLink.jsx'
import grouping from '../../../lib/metadata-edit-grouping.js'
import labelize from '../../../lib/labelize.js'

module.exports = {
  _renderValueFromWorkflowCommonSettings(workflow, meta_key_id) {
    const md = f.find(workflow.common_settings.meta_data, md => md.meta_key.uuid === meta_key_id)

    const value = f.has(md.value, '0.string') ? (
      md.value[0].string
    ) : (
      <TagCloud mod="person" mods="small" list={labelize(md.value)} />
    )

    const workflowLink = (
      <Link href={workflow.actions.edit.url} mods="strong">
        {workflow.name}
      </Link>
    )
    const info = (
      <span style={{ fontStyle: 'italic' }}>
        {t('workflow_md_edit_form_key_is_managed_a')}
        &quot;{workflowLink}&quot;
        {t('workflow_md_edit_form_key_is_managed_b')}
      </span>
    )
    const arrowStyle = {
      fontSize: '0.75em',
      position: 'relative',
      top: '-2px'
    }

    return (
      <div className="form-item" style={{ paddingTop: '5px' }}>
        <div>{value || 'not set'}</div>
        <span style={arrowStyle}>⮑</span> {info}
      </div>
    )
  },

  _renderValueByContext(onChange, name, subForms, metaKey, batch, model, workflow) {
    const meta_key_id = metaKey.uuid

    if (batch) {
      name += `[${meta_key_id}][values][]`
    } else {
      name += `[${meta_key_id}][]`
    }

    const input = (
      <InputMetaDatum
        id={meta_key_id}
        model={model}
        name={name}
        onChange={onChange}
        subForms={subForms}
        metaKey={metaKey}
      />
    )

    if (
      workflow != null &&
      !!f.find(workflow.common_settings.meta_data, {
        is_common: true,
        meta_key: { uuid: meta_key_id }
      })
    ) {
      return this._renderValueFromWorkflowCommonSettings(workflow, meta_key_id)
    } else if (batch) {
      const style = { marginRight: '200px', marginLeft: '200px' }
      return <div style={style}>{input}</div>
    } else {
      return input
    }
  },

  _renderLabelByContext(meta_meta_data, context_key_id) {
    const contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]

    const { meta_key_id } = contextKey
    const mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]

    return (
      <MetaKeyFormLabel
        metaKey={meta_meta_data.meta_key_by_meta_key_id[meta_key_id]}
        contextKey={contextKey}
        mandatory={mandatory}
      />
    )
  },

  _renderLabelByVocabularies(meta_meta_data, meta_key_id) {
    const mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]

    return (
      <MetaKeyFormLabel
        metaKey={meta_meta_data.meta_key_by_meta_key_id[meta_key_id]}
        contextKey={null}
        mandatory={mandatory}
      />
    )
  },

  _renderBatchDropdown(meta_meta_data, meta_key_id, name, model, onChangeBatchAction) {
    const mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]
    if (mandatory) {
      return null
    }

    const style = { float: 'right', maxWidth: '195px' }

    const _onChange = function (event) {
      event.preventDefault()
      return onChangeBatchAction(meta_key_id, event.target.value)
    }

    name += `[${meta_key_id}][batch_action]`

    return (
      <div style={style}>
        <select name={name} value={model.batchAction} onChange={_onChange}>
          <option value="none">...</option>
          <option value="remove">{t('meta_data_batch_action_remove_meta_data')}</option>
        </select>
      </div>
    )
  },

  _renderItemByContext2(
    meta_meta_data,
    workflow,
    published,
    name,
    context_key_id,
    subForms,
    rowed,
    batch,
    model,
    batchConflict,
    errors,
    _onChangeForm
  ) {
    const contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]
    const { meta_key_id } = contextKey
    const metaKey = meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
    const mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]
    const error = errors[meta_key_id]
    const validErr = published && mandatory && !metadataEditValidation._validModel(model) && !batch
    const className = cx(
      'ui-form-group prh',
      { columned: !rowed },
      { rowed: rowed },
      { error: (error || validErr) && !batchConflict },
      { highlight: batchConflict }
    )

    return (
      <fieldset className={className} key={meta_key_id}>
        {error ? (
          <div className="ui-alerts" style={{ marginBottom: '10px' }}>
            <div className="error ui-alert">{error}</div>
          </div>
        ) : undefined}
        {this._renderLabelByContext(meta_meta_data, context_key_id)}
        {batch
          ? this._renderBatchDropdown(
              meta_meta_data,
              meta_key_id,
              name,
              model,
              _onChangeForm.onChangeBatchAction
            )
          : undefined}
        {this._renderValueByContext(
          values => _onChangeForm.onValue(meta_key_id, values),
          name,
          subForms,
          metaKey,
          batch,
          model,
          workflow
        )}
      </fieldset>
    )
  },

  _renderItemByVocabularies2(
    meta_meta_data,
    workflow,
    published,
    name,
    meta_key_id,
    subForms,
    rowed,
    batch,
    model,
    batchConflict,
    errors,
    _onChangeForm
  ) {
    const metaKey = meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
    const mandatory = meta_meta_data.mandatory_by_meta_key_id[meta_key_id]
    const error = errors[meta_key_id]
    const validErr = published && mandatory && !metadataEditValidation._validModel(model)
    const className = cx(
      'ui-form-group prh',
      { columned: !rowed },
      { rowed: rowed },
      { error: (error || validErr) && !batchConflict },
      { highlight: batchConflict }
    )

    return (
      <fieldset className={className} key={meta_key_id}>
        {error ? (
          <div className="ui-alerts" style={{ marginBottom: '10px' }}>
            <div className="error ui-alert">{error}</div>
          </div>
        ) : undefined}
        {this._renderLabelByVocabularies(meta_meta_data, meta_key_id)}
        {batch
          ? this._renderBatchDropdown(
              meta_meta_data,
              meta_key_id,
              name,
              model,
              _onChangeForm.onChangeBatchAction
            )
          : undefined}
        {this._renderValueByContext(
          values => _onChangeForm.onValue(meta_key_id, values),
          name,
          subForms,
          metaKey,
          batch,
          model,
          workflow
        )}
      </fieldset>
    )
  },

  _renderHiddenKeysByContext(meta_meta_data, currentContextId, batch, models, name) {
    const meta_key_ids_in_current_context = f.map(
      meta_meta_data.context_key_ids_by_context_id[currentContextId],
      function (context_key_id) {
        return meta_meta_data.meta_key_id_by_context_key_id[context_key_id]
      }
    )

    const all_meta_key_ids = f.keys(meta_meta_data.meta_key_by_meta_key_id)

    const hidden_meta_key_ids = f.select(
      all_meta_key_ids,
      meta_key_id => !f.includes(meta_key_ids_in_current_context, meta_key_id)
    )

    return f.map(hidden_meta_key_ids, meta_key_id => {
      const model = models[meta_key_id]
      const metaKey = meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
      return (
        <div style={{ display: 'none' }} key={meta_key_id}>
          {batch
            ? this._renderBatchDropdown(meta_meta_data, meta_key_id, name, model, function () {})
            : undefined}
          {this._renderValueByContext(function () {}, name, null, metaKey, batch, model)}
        </div>
      )
    })
  },

  _bundleHasOnlyOneKey(bundle) {
    return bundle.type === 'single' || (bundle.type === 'block' && f.size(bundle.content) === 0)
  },

  _bundleGetTheOnlyContent(bundle) {
    if (bundle.type === 'single') {
      return bundle.content
    } else {
      return bundle.mainKey
    }
  },

  _renderSubForms(bundle, bundleState, _toggleBundle, isInvalid, children) {
    const style = {
      display: bundleState[bundle.bundle] || isInvalid ? 'block' : 'none',
      marginTop: '10px',
      marginBottom: '20px'
    }

    return [
      <a
        key="sub-form-link"
        className={cx('button small form-item-extension-toggle mtm', { active: isInvalid })}
        onClick={!isInvalid ? () => _toggleBundle(bundle.bundle) : undefined}>
        <i className="icon-plus-small" /> {t('meta_data_edit_more_data')}
      </a>,
      <div
        style={style}
        className="ui-container pam ui-container bordered rounded form-item-extension hidden"
        key={`block_${bundle.bundle}`}>
        {children}
      </div>
    ]
  },

  _context_keys(meta_meta_data, context_id) {
    return f.map(
      meta_meta_data.context_key_ids_by_context_id[context_id],
      context_key_id => meta_meta_data.context_key_by_context_key_id[context_key_id]
    )
  },

  _renderByContext(
    context_id,
    meta_meta_data,
    workflow,
    published,
    name,
    batch,
    models,
    errors,
    _batchConflictByContextKey,
    _onChangeForm,
    bundleState,
    _toggleBundle
  ) {
    const bundled_context_keys = grouping._group_context_keys(
      this._context_keys(meta_meta_data, context_id)
    )

    const _renderItemByContextKeyId = (context_key_id, subForms, rowed) => {
      const contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]

      return this._renderItemByContext2(
        meta_meta_data,
        workflow,
        published,
        name,
        context_key_id,
        subForms,
        rowed,
        batch,
        models[contextKey.meta_key_id],
        _batchConflictByContextKey(context_key_id),
        errors,
        _onChangeForm
      )
    }

    return f.map(bundled_context_keys, bundle => {
      let context_key_id
      if (this._bundleHasOnlyOneKey(bundle)) {
        context_key_id = this._bundleGetTheOnlyContent(bundle).uuid
        return _renderItemByContextKeyId(context_key_id, null, false)
      } else {
        const subFormIsInvalid =
          metadataEditValidation._validityForMetaKeyIds(
            meta_meta_data,
            models,
            f.map(bundle.content, 'meta_key_id')
          ) === 'invalid'

        const children = f.map(bundle.content, entry =>
          _renderItemByContextKeyId(entry.uuid, null, true)
        )

        const subForms = this._renderSubForms(
          bundle,
          bundleState,
          _toggleBundle,
          subFormIsInvalid,
          children
        )

        context_key_id = bundle.mainKey.uuid
        return _renderItemByContextKeyId(context_key_id, subForms, false)
      }
    })
  },

  _sortedVocabularies(meta_meta_data) {
    return f.sortBy(f.values(meta_meta_data.vocabularies_by_vocabulary_id), function (vocabulary) {
      if (vocabulary.uuid === 'madek_core') {
        return -1
      } else {
        return vocabulary.position
      }
    })
  },

  _sortedMetadata(meta_meta_data, meta_data, vocabulary) {
    const meta_key_ids = meta_meta_data.meta_key_ids_by_vocabulary_id[vocabulary.uuid]

    const meta_keys = f.map(
      meta_key_ids,
      meta_key_id => meta_meta_data.meta_key_by_meta_key_id[meta_key_id]
    )

    const sorted = f.sortBy(meta_keys, 'position')

    return f.map(sorted, meta_key => meta_data.meta_datum_by_meta_key_id[meta_key.uuid])
  },

  _renderByVocabularies(
    meta_data,
    meta_meta_data,
    workflow,
    published,
    name,
    batch,
    models,
    errors,
    _batchConflictByMetaKey,
    _onChangeForm,
    bundleState,
    _toggleBundle
  ) {
    const sorted_vocabs = this._sortedVocabularies(meta_meta_data)

    return f.map(sorted_vocabs, vocabulary => {
      const vocabMetaData = this._sortedMetadata(meta_meta_data, meta_data, vocabulary)

      const bundled_meta_data = grouping._group_meta_data(vocabMetaData)

      const _renderItemByMetaKeyId = (meta_key_id, subForms, rowed) => {
        return this._renderItemByVocabularies2(
          meta_meta_data,
          workflow,
          published,
          name,
          meta_key_id,
          subForms,
          rowed,
          batch,
          models[meta_key_id],
          _batchConflictByMetaKey(meta_key_id),
          errors,
          _onChangeForm
        )
      }

      return (
        <div className="mbl" key={vocabulary.uuid}>
          <div className="ui-container pas">
            <VocabTitleLink
              id={vocabulary.uuid}
              text={vocabulary.label}
              separated={true}
              href={vocabulary.url}
            />
          </div>
          {f.map(bundled_meta_data, bundle => {
            let meta_key_id
            if (this._bundleHasOnlyOneKey(bundle)) {
              ;({ meta_key_id } = this._bundleGetTheOnlyContent(bundle))
              return _renderItemByMetaKeyId(meta_key_id, null, false)
            } else {
              const subFormIsInvalid =
                metadataEditValidation._validityForMetaKeyIds(
                  meta_meta_data,
                  models,
                  f.map(bundle.content, 'meta_key_id')
                ) === 'invalid'

              const children = f.map(bundle.content, entry =>
                _renderItemByMetaKeyId(entry.meta_key_id, null, true)
              )

              const subForms = this._renderSubForms(
                bundle,
                bundleState,
                _toggleBundle,
                subFormIsInvalid,
                children
              )

              ;({ meta_key_id } = bundle.mainKey)
              return _renderItemByMetaKeyId(meta_key_id, subForms, false)
            }
          })}
        </div>
      )
    })
  },

  _renderVocabQuickLinks(meta_data, meta_meta_data) {
    let vocabularies
    return (
      <div className="ui-container pas">
        <div style={{ paddingBottom: '30px' }}>
          {
            ((vocabularies = this._sortedVocabularies(meta_meta_data)),
            f.flatten(
              f.map(vocabularies, (vocabulary, index) => {
                return [
                  <span
                    className="title-l"
                    key={`href_${vocabulary.uuid}`}
                    style={{ fontWeight: 'normal' }}>
                    <a href={`#${vocabulary.uuid}`}>{vocabulary.label}</a>
                  </span>,
                  index !== vocabularies.length - 1 ? (
                    <span
                      className="title-l"
                      key={`separator_${vocabulary.uuid}`}
                      style={{ paddingRight: '10px', paddingLeft: '10px', fontWeight: 'normal' }}>
                      |
                    </span>
                  ) : undefined
                ]
              })
            ))
          }
        </div>
        <div style={{ clear: 'both' }} />
      </div>
    )
  },

  _renderThumbnail(resource, displayMetaData, href = null) {
    if (displayMetaData == null) {
      displayMetaData = true
    }
    const src = resource.image_url

    if (resource.media_file && resource.media_file.previews) {
      const { previews } = resource.media_file
      href = href || f.chain(previews.images).sortBy('width').last().get('url').run()
    }

    const alt = ''
    const image = src ? (
      <Picture mods="ui-thumbnail-image" src={src} alt={alt} />
    ) : (
      <ResourceIcon thumbnail={true} mediaType={resource.media_type} type={resource.type} />
    )

    const className =
      resource.type === 'Collection' ? 'media-set ui-thumbnail' : 'image media-entry ui-thumbnail'

    return (
      <div className="app-body-sidebar table-cell ui-container table-side">
        <ul className="ui-resources grid">
          <li className="ui-resource mrl">
            <div className={className}>
              <div className="ui-thumbnail-privacy">
                <i className="icon-privacy-private" title={t('contents_privacy_private')} />
              </div>
              <div className="ui-thumbnail-image-wrapper">
                {href ? (
                  <div className="ui-has-magnifier">
                    <a href={href} target="_blank" rel="noreferrer">
                      <div className="ui-thumbnail-image-holder">
                        <div className="ui-thumbnail-table-image-holder">
                          <div className="ui-thumbnail-cell-image-holder">
                            <div className="ui-thumbnail-inner-image-holder">{image}</div>
                          </div>
                        </div>
                      </div>
                    </a>
                    <a
                      href={href}
                      target="_blank"
                      className="ui-magnifier"
                      style={{ textDecoration: 'none' }}
                      rel="noreferrer">
                      <Icon i="magnifier" mods="bright" />
                    </a>
                  </div>
                ) : (
                  <div className="ui-thumbnail-image-holder">
                    <div className="ui-thumbnail-table-image-holder">
                      <div className="ui-thumbnail-cell-image-holder">
                        <div className="ui-thumbnail-inner-image-holder">{image}</div>
                      </div>
                    </div>
                  </div>
                )}
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
    )
  },

  _renderTabs(
    meta_meta_data,
    batch,
    batch_ids,
    return_to,
    url,
    onTabClick,
    currentTab,
    collection_id,
    resource_type,
    edit_by_context_urls,
    edit_by_context_fallback_url,
    batch_edit_by_context_urls,
    batch_edit_by_context_fallback_url,
    edit_by_vocabularies_url,
    batch_edit_by_vocabularies_url,
    batch_edit_all_collection_url,
    show_all_meta_data_tab
  ) {
    let tabUrl, nextCurrentTab, active
    return (
      <Tabs>
        {f.map(meta_meta_data.meta_data_edit_context_ids, function (context_id) {
          const context = meta_meta_data.contexts_by_context_id[context_id]
          tabUrl = (() => {
            if (batch) {
              if (collection_id) {
                return setUrlParams(batch_edit_all_collection_url, {
                  type: resource_type,
                  context_id: context.uuid,
                  by_vocabulary: false,
                  return_to
                })
              } else {
                url = f.get(
                  batch_edit_by_context_urls,
                  context.uuid,
                  batch_edit_by_context_fallback_url
                )
                return setUrlParams(url, {
                  id: batch_ids,
                  return_to
                })
              }
            } else {
              url = f.get(edit_by_context_urls, context.uuid, edit_by_context_fallback_url)
              return setUrlParams(url, { return_to })
            }
          })()

          if (!f.isEmpty(meta_meta_data.context_key_ids_by_context_id[context_id])) {
            nextCurrentTab = {
              byContext: context_id,
              byVocabularies: false
            }

            active = !currentTab.byVocabularies && currentTab.byContext === context.uuid

            return (
              <Tab
                privacyStatus="public"
                key={context.uuid}
                iconType={null}
                onClick={f.curry(onTabClick)(nextCurrentTab)}
                href={tabUrl}
                label={context.label}
                active={active}
              />
            )
          }
        })}
        {(() => {
          if (show_all_meta_data_tab) {
            tabUrl = batch
              ? collection_id
                ? setUrlParams(batch_edit_all_collection_url, {
                    type: resource_type,
                    context_id: null,
                    by_vocabulary: true,
                    return_to
                  })
                : setUrlParams(batch_edit_by_vocabularies_url, {
                    id: batch_ids,
                    return_to
                  })
              : setUrlParams(edit_by_vocabularies_url, { return_to })

            nextCurrentTab = {
              byContext: null,
              byVocabularies: true
            }

            active = currentTab.byVocabularies

            return (
              <Tab
                privacyStatus="public"
                key="byVocabularies"
                iconType={null}
                onClick={f.curry(onTabClick)(nextCurrentTab)}
                href={tabUrl}
                label={t('meta_data_form_all_data')}
                active={active}
              />
            )
          }
        })()}
      </Tabs>
    )
  }
}
