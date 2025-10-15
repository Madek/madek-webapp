/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import t from '../../lib/i18n-translate.js'
import setUrlParams from '../../lib/set-params-for-url.js'
import { parse as parseUrl, format as formatUrl } from 'url'

import Modal from '../ui-components/Modal.jsx'
import BatchHintBox from './BatchHintBox.jsx'
import ResourcesBatchBox from './ResourcesBatchBox.jsx'
import PageContent from '../views/PageContent.jsx'
import PageContentHeader from '../views/PageContentHeader.jsx'
import TabContent from '../views/TabContent.jsx'

import xhr from 'xhr'
import RailsForm from '../lib/forms/rails-form.jsx'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

import validation from '../../lib/metadata-edit-validation.js'
import Renderer from './metadataedit/MetadataEditRenderer.jsx'

module.exports = createReactClass({
  displayName: 'ResourceMetaDataPagePerContext',

  _onTabClick(currentTab, event) {
    event.preventDefault()
    this.setState({ currentTab })
    return false
  },

  getInitialState() {
    return {
      mounted: false,
      currentTab: {
        byContext: null,
        byVocabularies: false
      },
      // currentContextId: null
      models: {},
      batchDiff: {},
      editing: false,
      errors: {},
      saving: false,
      systemError: false,
      bundleState: {}
    }
  },

  _actionUrl() {
    let actionType, url
    const automaticPublish =
      validation._validityForAll(this.props.get.meta_meta_data, this.state.models) === 'valid' &&
      this.state.mounted === true &&
      !this.props.get.published
    if (automaticPublish) {
      actionType = 'publish'
    } else {
      actionType = 'save'
    }

    if (this.props.get.collection_id) {
      const path = this.props.get.batch_update_all_collection_url

      return (url = setUrlParams(path, {
        return_to: this.props.get.return_to,
        type: this.props.get.resource_type,
        collection_id: this.props.get.collection_id,
        actionType
      }))
    } else {
      const parsedUrl = parseUrl(this.props.get.submit_url, true)

      if (this.props.batch) {
        actionType = 'save'
      }

      delete parsedUrl.search
      parsedUrl.query['actionType'] = actionType

      url = formatUrl(parsedUrl)

      // Note: Return to must be a hidden field to for the server-side case.
      // Url parameters are ignored in the <form action=... field.
      return (url = setUrlParams(url, { return_to: this.props.get.return_to }))
    }
  },

  _createModelForMetaKey(meta_key) {
    return {
      multiple: (() => {
        switch (meta_key.value_type) {
          case 'MetaDatum::Text':
          case 'MetaDatum::TextDate':
            return false
          case 'MetaDatum::Keywords':
            return meta_key.multiple
          default:
            return true
        }
      })(),
      meta_key,
      values: [],
      originalValues: [],
      batchAction: 'none'
    }
  },

  _createaModelsForMetaKeys(meta_meta_data, meta_data, diff) {
    const models = f.mapValues(meta_meta_data.meta_key_by_meta_key_id, meta_key => {
      return this._createModelForMetaKey(meta_key)
    })

    f.each(
      meta_data.meta_datum_by_meta_key_id,
      (data, meta_key_id) => (models[meta_key_id].values = data.values)
    )

    f.each(models, model => (model.originalValues = f.map(model.values, value => value)))

    if (diff) {
      f.each(models, function (model, meta_key_id) {
        if (!diff[meta_key_id].all_equal) {
          model.originalValues = []
          return (model.values = [])
        }
      })
    }

    return models
  },

  _determineCurrentTab(context_id, by_vocabularies, meta_meta_data) {
    if (by_vocabularies) {
      return {
        byContext: null,
        byVocabularies: true
      }
    } else {
      if (context_id) {
        return {
          byContext: context_id,
          byVocabularies: false
        }
      } else {
        return {
          byContext: meta_meta_data.meta_data_edit_context_ids[0],
          byVocabularies: false
        }
      }
    }
  },

  componentDidMount() {
    this.setState({ mounted: true })

    let diff
    const currentTab = this._determineCurrentTab(
      this.props.get.context_id,
      this.props.get.by_vocabularies,
      this.props.get.meta_meta_data
    )
    this.setState({ currentTab })

    if (this.props.batch) {
      if (this.props.get.batch_diff) {
        diff = f.mapValues(this.props.get.meta_meta_data.meta_key_by_meta_key_id, meta_key => {
          diff = f.find(this.props.get.batch_diff, { meta_key_id: meta_key.uuid })
          if (!diff) {
            return {
              all_equal: true,
              all_empty: true
            }
          } else {
            return {
              all_equal: diff.count === diff.max,
              all_empty: false
            }
          }
        })
      } else {
        throw new Error('Not supported anymore.')
      }

      this.setState({ batchDiff: diff })
    }

    const models = this._createaModelsForMetaKeys(
      this.props.get.meta_meta_data,
      this.props.get.meta_data,
      diff
    )
    this.setState({ models })
  },

  _onChangeForm(meta_key_id, values) {
    const { models } = this.state
    models[meta_key_id].values = values
    return this.setState({ models })
  },

  _onChangeBatchAction(meta_key_id, batchAction) {
    const { models } = this.state
    models[meta_key_id].batchAction = batchAction
    return this.setState({ models })
  },

  submit() {
    this.setState({ saving: true, systemError: false })
    const serialized = this.refs.form.serialize()
    return xhr(
      {
        method: 'PUT',
        url: this._actionUrl(),
        body: serialized,
        headers: {
          Accept: 'application/json',
          'Content-type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, body) => {
        let data
        if (err) {
          window.scrollTo(0, 0)
          if (this.isMounted()) {
            this.setState({ saving: false, systemError: 'Connection error. Please try again.' })
          }
          return
        }

        try {
          data = JSON.parse(body)

          // eslint-disable-next-line no-unused-vars
        } catch (e) {
          window.scrollTo(0, 0)
          if (this.isMounted()) {
            this.setState({
              saving: false,
              systemError: 'System error. Cannot parse server answer. Please try again.'
            })
          }
          return
        }

        if (res.statusCode === 400) {
          const errors = f.presence(f.get(data, 'errors')) || {}
          if (!f.present(errors)) {
            window.scrollTo(0, 0)
            if (this.isMounted()) {
              return this.setState({
                saving: false,
                systemError: 'System error. Cannot read server errors. Please try again.'
              })
            }
          } else {
            window.scrollTo(0, 0)
            if (this.isMounted()) {
              return this.setState({ saving: false })
            }
          }
        } else {
          const forward_url = data['forward_url']
          if (!forward_url) {
            window.scrollTo(0, 0)
            if (this.isMounted()) {
              return this.setState({
                saving: false,
                systemError: 'Cannot read forward url. Please try again.'
              })
            }
          } else {
            return (window.location = forward_url)
          }
        }
      }
    )
  },

  // NOTE: just to be save, block *implicit* form submits
  // (should normally not be triggered when button[type=button] is used.)
  _onImplicitSumbit(event) {
    return event.preventDefault()
  },

  _onExplicitSubmit(event) {
    event.preventDefault()
    this.submit(event.target.value)
    return false
  },

  _toggleBundle(bundleId) {
    const current = this.state.bundleState[bundleId]
    const next = !current
    return this.setState({ bundleState: f.set(this.state.bundleState, bundleId, next) })
  },

  _batchConflictByContextKey(context_key_id) {
    const { meta_meta_data } = this.props.get
    const contextKey = meta_meta_data.context_key_by_context_key_id[context_key_id]
    const { meta_key_id } = contextKey
    return this._batchConflictByMetaKey(meta_key_id)
  },

  _batchConflictByMetaKey(meta_key_id) {
    const batchConflict = this.state.batchDiff[meta_key_id]
    if (batchConflict) {
      return !batchConflict.all_equal
    } else {
      return false
    }
  },

  _title(get) {
    let title = null
    if (this.props.batch) {
      const pre_title = t('meta_data_batch_title_pre')
      const post_title =
        this.props.get.resource_type === 'media_entry'
          ? t('meta_data_batch_title_post_media_entries')
          : t('meta_data_batch_title_post_collections')

      title = pre_title + get.batch_length + post_title
    } else {
      if (get.resource.type === 'Collection') {
        title = t('collection_meta_data_header_prefix') + get.resource.title
      } else {
        title = t('media_entry_meta_data_header_prefix') + get.resource.title
      }
    }
    return title
  },

  _disableSave(atLeastOnePublished, batch) {
    if (this.state.saving) {
      return true
    }

    if (!this.state.mounted) {
      return false
    }

    if (batch) {
      return false
    } else {
      return (
        validation._validityForAll(this.props.get.meta_meta_data, this.state.models) ===
          'invalid' && atLeastOnePublished
      )
    }
  },

  _disablePublish() {
    return (
      this.state.saving ||
      validation._validityForAll(this.props.get.meta_meta_data, this.state.models) !== 'valid'
    )
  },

  _showNoContextDefinedIfNeeded() {
    return (
      <div className="ui-alerts">
        <div className="ui-alert warning">{`\
There are no contexts defined. Please configure them in the admin tool.\
`}</div>
      </div>
    )
  },

  _namePrefix(resource, batch, batch_resource_type) {
    if (batch) {
      return batch_resource_type + '[meta_data]'
    } else {
      return `${f.snakeCase(resource.type)}[meta_data]`
    }
  },

  _atLeastOnePublished() {
    if (this.props.batch) {
      return this.props.get.at_least_one_published
    } else {
      return this.props.get.published
    }
  },

  contextDescription(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    const { currentTab } = this.state
    const currentContext = currentTab != null ? currentTab.byContext : undefined
    const description = f.get(get, [
      'meta_meta_data',
      'contexts_by_context_id',
      currentContext,
      'description'
    ])

    if (description) {
      return <div className="context-description mbm">{description}</div>
    }
  },

  render(param) {
    // First make sure that you do not get a system error page when you have no context configured.
    let currentContextId
    if (param == null) {
      param = this.props
    }
    const { get, authToken } = param
    if (get.meta_meta_data.meta_data_edit_context_ids.length === 0) {
      return this._showNoContextDefinedIfNeeded()
    }

    const { currentTab } = this.state

    const name = this._namePrefix(get.resource, this.props.batch, get.resource_type)

    const published = this._atLeastOnePublished()

    return (
      <PageContent>
        {this.state.saving ? (
          <Modal widthInPixel={400}>
            <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
              {t('meta_data_form_saving')}
            </div>
          </Modal>
        ) : undefined}
        <PageContentHeader icon="pen" title={this._title(get)} />
        {this.props.batch ? (
          <ResourcesBatchBox
            batchCount={this.props.get.batch_length}
            counts={this.props.get.counts}
            resources={get.resources.resources}
            authToken={authToken}
          />
        ) : undefined}
        {Renderer._renderTabs(
          this.props.get.meta_meta_data,
          this.props.batch,
          this.props.get.batch_ids,
          this.props.get.return_to,
          this.props.get.url,
          this._onTabClick,
          currentTab,
          get.collection_id,
          this.props.get.resource_type,
          get.edit_by_context_urls,
          get.edit_by_context_fallback_url,
          get.batch_edit_by_context_urls,
          get.batch_edit_by_context_fallback_url,
          get.edit_by_vocabularies_url,
          get.batch_edit_by_vocabularies_url,
          get.batch_edit_all_collection_url,
          this.props.get.show_all_meta_data_tab
        )}
        <TabContent>
          <RailsForm
            ref="form"
            name="resource_meta_data"
            action={this._actionUrl()}
            onSubmit={this._onImplicitSumbit}
            method="put"
            authToken={authToken}>
            <input type="hidden" name="return_to" value={this.props.get.return_to} />
            <div className="ui-container phl ptl">
              {this.contextDescription()}
              {!this.props.batch ? Renderer._renderThumbnail(this.props.get.resource) : undefined}
              <div className="app-body-content table-cell ui-container table-substance ui-container">
                <div className={'active'}>
                  {this.state.systemError ? (
                    <div className="ui-alerts" style={{ marginBottom: '10px' }}>
                      <div className="error ui-alert">{this.state.systemError}</div>
                    </div>
                  ) : undefined}
                  {this.state.errors && f.keys(this.state.errors).length > 0 ? (
                    <div className="ui-alerts" style={{ marginBottom: '10px' }}>
                      <div className="error ui-alert">
                        {t('resource_meta_data_has_validation_errors')}
                      </div>
                    </div>
                  ) : undefined}
                  <div className="form-body">
                    {this.props.batch && !get.collection_id
                      ? f.map(get.batch_ids, id => (
                          <input
                            key={id}
                            type="hidden"
                            name="batch_resource_meta_data[id][]"
                            value={id}
                          />
                        ))
                      : undefined}
                    {currentTab.byVocabularies
                      ? Renderer._renderVocabQuickLinks(get.meta_data, get.meta_meta_data)
                      : undefined}
                    {(() => {
                      if (!currentTab.byVocabularies) {
                        currentContextId = currentTab.byContext
                        return Renderer._renderByContext(
                          currentContextId,
                          get.meta_meta_data,
                          get.workflow,
                          published,
                          name,
                          this.props.batch,
                          this.state.models,
                          this.state.errors,
                          this._batchConflictByContextKey,
                          {
                            onValue: this._onChangeForm,
                            onChangeBatchAction: this._onChangeBatchAction
                          },
                          this.state.bundleState,
                          this._toggleBundle
                        )
                      } else {
                        return Renderer._renderByVocabularies(
                          get.meta_data,
                          get.meta_meta_data,
                          get.workflow,
                          published,
                          name,
                          this.props.batch,
                          this.state.models,
                          this.state.errors,
                          this._batchConflictByMetaKey,
                          {
                            onValue: this._onChangeForm,
                            onChangeBatchAction: this._onChangeBatchAction
                          },
                          this.state.bundleState,
                          this._toggleBundle
                        )
                      }
                    })()}
                    {(() => {
                      if (!currentTab.byVocabularies) {
                        const currentContext =
                          get.meta_meta_data.contexts_by_context_id[currentContextId]
                        return Renderer._renderHiddenKeysByContext(
                          this.props.get.meta_meta_data,
                          currentContext.uuid,
                          this.props.batch,
                          this.state.models,
                          name
                        )
                      }
                    })()}
                  </div>
                </div>
              </div>
              {this.props.batch ? <BatchHintBox /> : undefined}
            </div>
            <div className="ui-actions phl pbl mtl">
              <a className="link weak" href={get.return_to || get.resource.url}>{` ${t(
                'meta_data_form_cancel'
              )} `}</a>
              <button
                className="primary-button large"
                type={this.state.mounted ? 'button' : 'submit'}
                name="actionType"
                value="save"
                onClick={this._onExplicitSubmit}
                disabled={this._disableSave(published, this.props.batch)}>
                {t('meta_data_form_save')}
              </button>
            </div>
          </RailsForm>
        </TabContent>
      </PageContent>
    )
  }
})
