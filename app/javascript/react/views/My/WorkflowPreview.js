import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate'
import cx from 'classnames'

import Renderer from '../../decorators/metadataedit/MetadataEditRenderer.jsx'
import WorkflowCommonPermissions from '../../decorators/WorkflowCommonPermissions'
import SubSection from '../../ui-components/SubSection'
import RailsForm from '../../lib/forms/rails-form.jsx'
import validation from '../../../lib/metadata-edit-validation.js'

class WorkflowPreview extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      models: {},
      errors: {},
      initialErrors: {},
      isFinishing: false,
      isSaving: false,
      formAction: props.get.actions.finish.url
    }
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleValueChange = this.handleValueChange.bind(this)
    this.handleSaveData = this.handleSaveData.bind(this)
  }

  handleSubmit(e) {
    if (
      !confirm(
        "You're about to finish the workflow. This action cannot be undone. Do you want to proceed?"
      )
    ) {
      e.preventDefault()
    } else {
      this.setState({ isFinishing: true })
    }
  }

  collectResources() {
    const resources = [this.props.get.master_collection]

    function getChildResources(r) {
      f.each(r.child_resources, childResource => {
        resources.push(childResource)
        getChildResources(childResource)
      })
    }

    getChildResources(resources[0])

    return resources
  }

  UNSAFE_componentWillMount() {
    const { errors, models, initialErrors } = this.state
    const { workflow } = this.props.get.master_collection

    f.each(this.collectResources(), childResource => {
      const {
        meta_data: { meta_datum_by_meta_key_id },
        uuid: resourceId,
        meta_meta_data: { meta_key_by_meta_key_id },
        type
      } = childResource

      errors[resourceId] = []
      initialErrors[resourceId] = []

      f.each(meta_key_by_meta_key_id, (meta_key, metaKeyId) => {
        const metaData = f.find(
          workflow.common_settings.meta_data,
          md => md.meta_key.uuid === metaKeyId
        )
        if (!metaData) return
        const position = f.get(metaData, 'position')
        let metaDataValue = f.get(metaData, 'value')
        if (f.has(metaDataValue, '0.string')) {
          metaDataValue = metaDataValue[0].string
        }
        if (!metaData.is_common) {
          metaDataValue = ''
        }
        const isMultiple = valueType => {
          switch (valueType) {
            case 'MetaDatum::Text':
            case 'MetaDatum::TextDate':
            case 'MetaDatum::JSON':
              return false
            case 'MetaDatum::Keywords':
              return meta_key.multiple
            default:
              return true
          }
        }
        const model = {
          meta_key: meta_key,
          type: type,
          multiple: isMultiple(meta_key.value_type),
          values: f.flatten(
            f.remove([meta_datum_by_meta_key_id[metaKeyId].values, metaDataValue]),
            arr => f.isEmpty(f.compact(arr))
          )
        }
        model.originalValues = model.values

        f.set(models, [resourceId, position], model)

        const validationModel = {
          [metaKeyId]: model
        }
        if (
          validation._validityForAll(childResource.meta_meta_data, validationModel) === 'invalid'
        ) {
          errors[resourceId].push(metaKeyId)
          initialErrors[resourceId].push(metaKeyId)
        }
      })

      this.setState({ models, errors, initialErrors })
    })
  }

  handleValueChange(values, metaKeyId, childResource) {
    const { errors, models } = this.state
    const { uuid: resourceId, meta_meta_data } = childResource
    const modelIndex = f.findIndex(models[resourceId], model => {
      return f.get(model, 'meta_key.uuid') === metaKeyId
    })

    f.set(models, [resourceId, modelIndex, 'values'], values)

    if (
      f.has(errors, resourceId) &&
      f.isArray(errors[resourceId]) &&
      f.includes(errors[resourceId], metaKeyId)
    ) {
      f.remove(errors[resourceId], x => x === metaKeyId)
    }

    const validationModel = {
      [metaKeyId]: f.get(models, [resourceId, modelIndex])
    }
    if (validation._validityForAll(meta_meta_data, validationModel) === 'invalid') {
      errors[resourceId].push(metaKeyId)
    }

    this.setState({ models, errors })
  }

  handleSaveData() {
    this.setState({
      isSaving: true,
      formAction: this.props.get.actions.save_and_not_finish.url
    })
  }

  componentDidUpdate(prevProps, prevState) {
    if (
      prevState.formAction !== this.state.formAction &&
      this.state.formAction === this.props.get.actions.save_and_not_finish.url
    ) {
      ReactDOM.findDOMNode(this.form).submit()
    }
  }

  hasErrors() {
    return !f.every(f.values(this.state.errors), arr => f.isEmpty(arr))
  }

  countResourcesByType(resource) {
    const counts = f.reduce(
      resource.child_resources,
      (result, child) => {
        result[child.type] += 1
        return result
      },
      { MediaEntry: 0, Collection: 0 }
    )
    const entrySuffix = counts['MediaEntry'] === 0 || counts['MediaEntry'] > 1 ? 'Entries' : 'Entry'
    const collectionSuffix =
      counts['Collection'] === 0 || counts['Collection'] > 1 ? 'Collections' : 'Collection'

    return `${counts['MediaEntry']} ${entrySuffix} and ${counts['Collection']} ${collectionSuffix}`
  }

  collectErrors(resource, source = 'errors') {
    const errors = f.get(this.state, source)
    let count = errors[resource.uuid].length

    if (resource.type === 'MediaEntry') {
      return errors[resource.uuid].length
    }

    function collectChildErrorsOf(parent) {
      return f.reduce(
        parent.child_resources,
        (result, child) => {
          const resourceId = child.uuid
          if (!f.isEmpty(errors[resourceId])) {
            result += errors[resourceId].length
          }
          return result + collectChildErrorsOf(child)
        },
        0
      )
    }

    count += collectChildErrorsOf(resource)

    return count
  }

  renderResource(childResource, isFillDataMode) {
    const { resource, type, uuid: resourceId, child_resources } = childResource
    const title = f.presence(f.get(resource, 'title') || '')
    const { models, errors /*initialErrors*/ } = this.state
    const hasErrors = this.collectErrors(childResource) > 0
    const hasInitialErrors = this.collectErrors(childResource, 'initialErrors')
    const headColor = hasErrors ? 'red' : 'green'
    const suffix = hasErrors
      ? `${this.collectErrors(childResource)} ${t('workflow_preview_errors_found')}`
      : ''
    const icon = hasErrors ? <span className="icon-close" /> : <span className="icon-checkmark" />
    const supHeadStyle = { textTransform: 'uppercase', fontSize: '85%', letterSpacing: '0.15em' }
    const counterStyle = { fontWeight: 'normal', fontFamily: 'monospace', letterSpacing: '-0.45px' }

    return (
      <SubSection startOpen={isFillDataMode ? isFillDataMode : hasInitialErrors} key={resourceId}>
        <SubSection.Title tag="span" className="title-s mts">
          <span>{resource.type}</span>
          {!!title && <span>{` "${title}"`}</span>}
          <span style={{ color: headColor }} className="mhx">
            {suffix} {icon}
          </span>
          {type === 'Collection' && (
            <span style={counterStyle} className="mlx">
              (consists of {this.countResourcesByType(childResource)})
            </span>
          )}
        </SubSection.Title>

        <div className="ui-container bordered pal mbs">
          <span style={supHeadStyle}>{type}</span>
          <div className="app-body-sidebar table-cell ui-container table-side prm">
            {Renderer._renderThumbnail(resource, false, resource.url)}
          </div>
          <div className="app-body-content table-cell ui-container table-substance ui-container">
            {f.map(models[resourceId], model => {
              const metaKey = f.get(model, 'meta_key')
              if (!metaKey) return
              const metaKeyId = metaKey.uuid
              const hasError = f.include(errors[resourceId], metaKeyId)

              return (
                <Fieldset
                  childResource={childResource}
                  metaKey={metaKey}
                  hasError={hasError}
                  model={model}
                  handleValueChange={this.handleValueChange}
                  key={metaKeyId}
                />
              )
            })}
          </div>

          {child_resources && !f.isEmpty(child_resources) && (
            <div className="mtl">
              <div style={supHeadStyle} className="title-s mbs">
                Resources:
              </div>
              {f.map(child_resources, child => this.renderResource(child, isFillDataMode))}
            </div>
          )}
        </div>
      </SubSection>
    )
  }

  render() {
    const { get, authToken } = this.props
    const childResources = get.child_resources
    const masterCollection = get.master_collection
    const commonPermissions = get.common_settings.permissions
    const { /*models,*/ /*errors,*/ /*initialErrors,*/ isFinishing, isSaving } = this.state
    const supHeadStyle = { textTransform: 'uppercase', fontSize: '85%', letterSpacing: '0.15em' }
    const submitBtnClass = cx('button primary-button large', { disabled: isFinishing })
    const showPermissionsOnBottom = childResources.length > 30
    const numberOfResources = f.reduce(
      childResources,
      (result, r) => {
        if (!f.get(result, r.type)) {
          f.set(result, r.type, 0)
        }
        result[r.type] += 1
        return result
      },
      {}
    )
    const isFillDataMode = f.get(get, 'fill_data_mode', false)

    return (
      <section className="ui-container bright bordered rounded mas pam">
        <header>
          <span style={supHeadStyle}>{'Workflow'}</span>
        </header>
        {/*<Link href={get.actions.edit.url}>&larr; Go back to workflow</Link>*/}

        {!isFillDataMode && (
          <p className="mvm title-m">
            This will apply to everything contained in the Set <strong>{get.name}</strong>.
            Contained Collections: {numberOfResources['Collection']}, MediaEntries:{' '}
            {numberOfResources['MediaEntry']}
          </p>
        )}

        {!isFillDataMode && (
          <div className="ui-container bordered phl pvm mbs">
            <WorkflowCommonPermissions permissions={commonPermissions} showHeader={true} />
          </div>
        )}

        <RailsForm
          ref={form => (this.form = form)}
          name="resource_meta_data"
          onSubmit={this.handleSubmit}
          action={this.state.formAction}
          method={get.actions.finish.method}
          authToken={authToken}>
          {this.renderResource(masterCollection, isFillDataMode)}

          {showPermissionsOnBottom && !isFillDataMode && (
            <WorkflowCommonPermissions permissions={commonPermissions} showHeader={true} />
          )}

          <div className="ui-actions pts pbs">
            <a className="link weak" href={get.actions.edit.url}>
              {t('workflow_edit_actions_back')}
            </a>
            <button
              type="button"
              className="button large"
              disabled={isSaving || isFinishing}
              onClick={this.handleSaveData}>
              {isSaving
                ? t('workflow_edit_actions_save_data')
                : t('workflow_edit_actions_save_data')}
            </button>
            {!isFillDataMode && (
              <button
                type="submit"
                className={submitBtnClass}
                disabled={this.hasErrors() || isSaving}>
                {isFinishing
                  ? t('workflow_edit_actions_finishing')
                  : t('workflow_edit_actions_finish')}
              </button>
            )}
          </div>
        </RailsForm>
      </section>
    )
  }
}

module.exports = WorkflowPreview

class Fieldset extends React.Component {
  render() {
    const { childResource, metaKey, model, hasError, handleValueChange } = this.props
    const {
      meta_data: { meta_datum_by_meta_key_id },
      meta_meta_data,
      meta_meta_data: { mandatory_by_meta_key_id },
      uuid: resourceId,
      type,
      workflow
    } = childResource
    const { uuid: metaKeyId } = metaKey

    if (
      f.isEmpty(meta_datum_by_meta_key_id[metaKeyId].values) &&
      !f.has(mandatory_by_meta_key_id, metaKeyId) &&
      !f.includes(f.map(workflow.common_settings.meta_data, 'meta_key.uuid'), metaKeyId)
    ) {
      return null
    }

    const cssClass = cx('ui-form-group prh columned', { error: hasError })
    const fieldName = `meta_data[${type}][${resourceId}]`

    return (
      <fieldset className={cssClass}>
        {Renderer._renderLabelByVocabularies(meta_meta_data, metaKeyId)}
        {Renderer._renderValueByContext(
          values => handleValueChange(values, metaKeyId, childResource),
          fieldName,
          null,
          metaKey,
          false,
          model,
          workflow
        )}
      </fieldset>
    )
  }
}
