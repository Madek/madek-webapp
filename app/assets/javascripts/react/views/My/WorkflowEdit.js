import React from 'react'
import f from 'active-lodash'
import cx from 'classnames'

// import setUrlParams from '../../../lib/set-params-for-url.coffee'
// import AppRequest from '../../../lib/app-request.coffee'
// import asyncWhile from 'async/whilst'
// import { parse as parseUrl } from 'url'
// import { parse as parseQuery } from 'qs'
// import Moment from 'moment'
import currentLocale from '../../../lib/current-locale'
const UI = require('../../ui-components/index.coffee')
import SubSection from '../../ui-components/SubSection'
import ResourceThumbnail from '../../decorators/ResourceThumbnail.cjsx'
import InputMetaDatum from '../../decorators/InputMetaDatum.cjsx'
import WorkflowCommonPermissions from '../../decorators/WorkflowCommonPermissions'
import RailsForm from '../../lib/forms/rails-form.cjsx'
import appRequest from '../../../lib/app-request.coffee'
// import ui from '../../lib/ui.coffee'
// const t = ui.t
import I18nTranslate from '../../../lib/i18n-translate'
import labelize from '../../../lib/labelize'
let AutoComplete = false // client-side only!

// const fakeCallback = (a, b, c) => console.log([a, b, c]) // eslint-disable-line
const DEBUG_STATE = false // set to true when developing or debugging forms with state!

// TODO: move to translations.csv
const UI_TXT = {
  feature_title: { de: 'Prozess', en: 'Workflow' },

  associated_collections_title: { de: 'Set mit Inhalten', en: 'Set with content' },
  associated_collections_explain: {
    de: `In diesem Set enthaltene Inhalte können vor dem Abschluss nur als Teil dieses Prozesses bearbeitet werden.`,
    en: `Content contained in this set may only be considered as part of this workflow prior to completion to be edited.`
  },
  associated_collections_upload: { de: 'Medien hinzufügen', en: 'Add media' },

  workflow_owners_title: { de: 'Prozess-Besitzer', en: 'Workflow owners' },

  common_settings_title: { de: 'Gemeinsamer Datensatz', en: 'Common data' },
  common_settings_explain: {
    de: `Diese Daten und Einstellungen gelten für alle enthaltenen Inhalte und werden bei
     Prozessabschluss permanent angewendet.`,
    en: `These data and settings apply to all contents and are permanently applied at the end of the process.`
  },
  common_settings_permissions_title: { de: 'Berechtigungen', en: 'Permissions' },
  common_settings_permissions_responsible: { de: 'Verantwortlich', en: 'Responsible' },
  common_settings_permissions_write: { de: 'Schreib- und Leserechte', en: 'Read and write rights' },
  common_settings_permissions_read: { de: 'Nur Leserechte', en: 'Only reading rights' },
  common_settings_permissions_read_public: { de: 'Öffentlicher Zugriff', en: 'Public access' },
  common_settings_permissions_select_user: { de: 'Nutzer auswählen', en: 'Select user' },
  common_settings_permissions_add_user: { de: 'Nutzer hinzufügen', en: 'Add user' },
  common_settings_permissions_add_group: { de: 'Gruppe hinzufügen', en: 'Add group' },
  common_settings_permissions_add_api_client: { de: 'API-Client hinzufügen', en: 'Add API-Client' },
  common_settings_metadata_title: { de: 'MetaDaten', en: 'MetaData' },

  actions_back: { de: 'Zurück', en: 'Go back' },
  actions_validate: { de: 'Prüfen', en: 'Check' },
  actions_validating: { de: 'Prüfen…', en: 'Checking…' },
  actions_finish: { de: 'Abschliessen…', en: 'Finish…' },

  add_md_by_metakey: { de: 'Hinzufügen', en: 'Add' },
  adder_meta_key_already_used: { de: 'Metakey ist schon verwendet', en: 'Metakey already used' }
}

const t = key => {
  /* global APP_CONFIG */
  // FIXME: only works client-side for now, hardcode a fallback…
  const locale = f.get(APP_CONFIG, 'userLanguage') || 'de'
  return f.get(UI_TXT, [key, locale]) || I18nTranslate(key)
}

class WorkflowEdit extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      isEditingOwners: false,
      isSavingOwners: false,
      ownersUpdateError: null,
      isEditingPermissions: false,
      isSavingPermissions: false,
      permissionsUpdateError: null,
      isEditingMetadata: false,
      isSavingMetadata: false,
      metaDataUpdateError: null,
      isEditingName: false,
      isSavingName: false,
      isProcessing: false,
      isPreviewing: false,
      nameUpdateError: null,
      workflowOwners: props.get.workflow_owners,
      commonPermissions: props.get.common_settings.permissions,
      commonMetadata: props.get.common_settings.meta_data
    }

    this.actions = [
      'onToggleEditOwners',
      'onSaveOwners',
      'onToggleEditPermissions',
      'onSavePermissions',
      'onToggleEditMetadata',
      'onSaveMetadata',
      'onToggleEditName',
      'onSaveName',
      'handleFillDataClick',
      'handlePreviewClick'
    ].reduce((o, name) => ({ ...o, [name]: this[name].bind(this) }), {})
  }

  onToggleEditOwners(event) {
    event.preventDefault()
    this.setState(cur => ({ isEditingOwners: !cur.isEditingOwners }))
  }
  onSaveOwners(owners) {
    const action = f.get(this, 'props.get.actions.update_owners')
    if (!action) throw new Error()
    const finalState = { isEditingOwners: false, isSavingOwners: false }
    this.setState({ isSavingOwners: true })

    const body = {
      workflow: {
        owners: f.map(owners, 'uuid')
      }
    }

    appRequest({ url: action.url, method: action.method, json: body }, (err, res) => {
      if (err) {
        console.error(err) // eslint-disable-line no-console
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ ...finalState, ownersUpdateError: err })
      }
      console.log({ res }) // eslint-disable-line no-console
      const workflowOwners = f.get(res, 'body.workflow_owners')
      this.setState({ ...finalState, workflowOwners })
    })
  }

  onToggleEditPermissions(event) {
    event.preventDefault()
    // NOTE: Date instead of "true" because it's used as React-`key` for the "edit session",
    // this is done to enforce a freshly mounted component every time,
    // which is needed because we read props into state!
    this.setState(cur => ({ isEditingPermissions: cur.isEditingPermissions ? false : Date.now() }))
  }
  onSavePermissions(commonPermissions) {
    const action = f.get(this, 'props.get.actions.update')
    if (!action) throw new Error()
    const finalState = { isSavingPermissions: false, isEditingPermissions: false }
    this.setState({ isSavingPermissions: true })

    function prepareData(obj) {
      const { uuid, type } = obj;
      return { uuid, type };
    }

    // tranform form data into what is sent to server:
    const body = {
      workflow: {
        common_permissions: {
          responsible: f.get(commonPermissions, 'responsible.uuid'),
          read: f.map(commonPermissions.read, prepareData),
          write: f.map(commonPermissions.write, prepareData),
          read_public: commonPermissions.read_public
        }
      }
    }

    appRequest({ url: action.url, method: action.method, json: body }, (err, res) => {
      if (err) {
        console.error(err) // eslint-disable-line no-console
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ ...finalState, permissionsUpdateError: err })
      }
      console.log({ res }) // eslint-disable-line no-console
      const commonPermissions = f.get(res, 'body.common_settings.permissions')
      this.setState({ ...finalState, commonPermissions })
    })
  }

  onToggleEditMetadata(event) {
    event.preventDefault()
    this.setState(cur => ({ isEditingMetadata: cur.isEditingMetadata ? false : Date.now() }))
  }
  onSaveMetadata(commonMetadata) {
    const action = f.get(this, 'props.get.actions.update')
    if (!action) throw new Error()
    const finalState = { isSavingMetadata: false, isEditingMetadata: false }
    this.setState({ isSavingMetadata: true })

    function prepareObj(value) {
      if (f.has(value, 'string')) {
        return value
      } else if (f.has(value, 'isNew')) {
        let v = value
        if (f.has(value, 'role')) {
          v.role = value.role.id
        }
        return v
      } else if (f.has(value, 'role')) {
        return { uuid: value.uuid, role: value.role.id }
      } else {
        return { uuid: value.uuid }
      }
    }

    function prepareValue(value) {
      if (f.isString(value)) {
        return { string: value }
      } else if (f.isObject(value)) {
        return prepareObj(value)
      }
    }

    // tranform form data into what is sent to server:
    const body = {
      workflow: {
        common_meta_data: f.map(commonMetadata, md => ({
          meta_key_id: md.meta_key.uuid,
          value: f.map(md.value, prepareValue)
        }))
      }
    }

    appRequest({ url: action.url, method: action.method, json: body }, (err, res) => {
      if (err) {
        console.error(err) // eslint-disable-line no-console
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ finalState, metaDataUpdateError: err })
      }
      console.log({ res }) // eslint-disable-line no-console
      const commonMetadata = f.get(res, 'body.common_settings.meta_data')
      this.setState({ ...finalState, commonMetadata })
    })
  }

  onToggleEditName(event) {
    event.preventDefault()
    this.setState(cur => ({ isEditingName: cur.isEditingName ? false : Date.now() }))
  }
  onSaveName(name) {
    const action = f.get(this, 'props.get.actions.update')
    if (!action) throw new Error()
    const finalState = { isSavingName: false, isEditingName: false }
    this.setState({ isEditingName: true })

    // tranform form data into what is sent to server:
    const body = { workflow: { name } }

    appRequest({ url: action.url, method: action.method, json: body }, (err, res) => {
      if (err) {
        console.error(err) // eslint-disable-line no-console
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ finalState, metaDataUpdateError: err })
      }
      console.log({ res }) // eslint-disable-line no-console
      this.setState({ ...finalState, name: f.get(res, 'body.name') })
    })
  }

  handleFillDataClick(e) {
    if (this.state.isProcessing) {
      e.preventDefault()
    }
    this.setState({ isProcessing: true })
  }

  handlePreviewClick(e) {
    this.setState({ isPreviewing: true })
  }

  render({ props, state, actions } = this) {
    const { name, status } = props.get

    return (
      <div>
        <WorkflowEditor
          {...{ name, status, authToken: props.authToken, get: props.get }}
          {...state}
          {...actions}
        />
        {!!DEBUG_STATE && <ShowJSONData data={{ state, props }} />}
      </div>
    )
  }
}

const WorkflowEditor = ({
  name,
  status,
  authToken,

  get, // FIXME: remove this, replace with named props

  workflowOwners,
  isEditingOwners,
  onToggleEditOwners,
  isSavingOwners,
  onSaveOwners,

  commonPermissions,
  onToggleEditPermissions,
  isEditingPermissions,
  isSavingPermissions,
  onSavePermissions,

  commonMetadata,
  onToggleEditMetadata,
  isEditingMetadata,
  isSavingMetadata,
  onSaveMetadata,

  onToggleEditName,
  isEditingName,
  isSavingName,
  onSaveName,

  isProcessing,
  handleFillDataClick,
  isPreviewing,
  handlePreviewClick
}) => {
  const supHeadStyle = { textTransform: 'uppercase', fontSize: '85%', letterSpacing: '0.15em' }
  const headStyle = { lineHeight: '1.34' }
  const canEdit = get.permissions.can_edit
  const canEditOwners = get.permissions.can_edit_owners
  const canPreview = get.permissions.can_preview
  const isEditing = isEditingName || isEditingOwners || isEditingPermissions || isEditingMetadata

  return (
    <section className="ui-container bright bordered rounded mas pam">
      <header>
        <span style={supHeadStyle}>{t('feature_title')}</span>
        {!isEditingName ? (
          <h1 className="title-l" style={headStyle}>
            {name}
            {'  '}
            {canEdit && <EditButton onClick={onToggleEditName} />}
          </h1>
        ) : (
          <NameEditor
            key={isEditingName}
            name={name}
            onSave={onSaveName}
            isSaving={isSavingName}
            onCancel={onToggleEditName}
          />
        )}
      </header>

      <div>
        <SubSection>
          <SubSection.Title tag="h2" className="title-m mts">
            {t('associated_collections_title')}
          </SubSection.Title>

          <Explainer>{t('associated_collections_explain')}</Explainer>

          <div>
            <div className="ui-resources miniature" style={{ margin: 0 }}>
              {f.map(get.associated_collections, (collection, i) => (
                <ResourceThumbnail get={collection} key={i} />
              ))}
            </div>

            {canEdit && (
              <div className="button-group small mas">
                <a className="tertiary-button" href={get.actions.upload.url}>
                  <span>
                    <i className="icon-upload"></i>
                  </span>{' '}
                  {t('associated_collections_upload')}
                </a>
              </div>)
            }
          </div>
        </SubSection>

        <SubSection>
          <SubSection.Title tag="h2" className="title-m mts">
            {t('workflow_owners_title')}
          </SubSection.Title>
          {canEditOwners && <EditButton onClick={onToggleEditOwners} />}
          {isEditingOwners ? (
            <OwnersEditor
              workflowOwners={workflowOwners}
              onSave={onSaveOwners}
              isSaving={isSavingOwners}
              onCancel={onToggleEditOwners}
              creator={get.creator}
            />
          ) : (
            <UI.TagCloud mod="person" mods="small" list={labelize(workflowOwners)} />
          )}
        </SubSection>

        <SubSection>
          <SubSection.Title tag="h2" className="title-m mts">
            {t('common_settings_title')}
          </SubSection.Title>

          <Explainer>{t('common_settings_explain')}</Explainer>

          <h3 className="title-s mts">
            {t('common_settings_permissions_title')}
            {'  '}
            {!isEditingPermissions && canEdit && <EditButton onClick={onToggleEditPermissions} />}
          </h3>

          {isEditingPermissions ? (
            <PermissionsEditor
              key={isEditingPermissions}
              commonPermissions={commonPermissions}
              isSaving={isSavingPermissions}
              onCancel={onToggleEditPermissions}
              onSave={onSavePermissions}
            />
          ) : (
            <WorkflowCommonPermissions permissions={commonPermissions} />
          )}

          <h3 className="title-s mts">
            {t('common_settings_metadata_title')}
            {'  '}
            {!isEditingPermissions && canEdit && <EditButton onClick={onToggleEditMetadata} />}
          </h3>

          {isEditingMetadata ? (
            <MetadataEditor
              key={isEditingMetadata}
              commonMetadata={commonMetadata}
              isSaving={isSavingMetadata}
              onCancel={onToggleEditMetadata}
              onSave={onSaveMetadata}
            />
          ) : (
            <ul>
              {commonMetadata.map(({ meta_key, value }) => {
                return <li key={meta_key.uuid}>
                  <b>{meta_key.label}:</b>
                  {' '}
                  {f.has(value, '0.string') ? (
                    value[0].string
                  ) : (
                    <UI.TagCloud mod="person" mods="small inline" list={labelize(value)} />
                  )}
                </li>
              })}
            </ul>
          )}
        </SubSection>
      </div>

      <div className="ui-actions phl pbl mtl">
        <a className="link weak" href={get.actions.index.url}>
          {t('actions_back')}
        </a>
        <a
          className={cx('button large', { disabled: isProcessing })}
          href={get.actions.fill_data.url}
          onClick={handleFillDataClick}
        >
          {isProcessing ? 'Processing...' : 'Fill Data'}
        </a>
        <PreviewButton
          canPreview={canPreview}
          isEditing={isEditing}
          isPreviewing={isPreviewing}
          previewUrl={get.actions.preview.url}
          handleClick={handlePreviewClick}
        />
        {/*
        <button className="tertiary-button large" type="button">
          {t('actions_validate')}
        </button>
        */}
        {canEdit && false && (
          <RailsForm
            action={get.actions.preview.url}
            method={get.actions.preview.method}
            name="workflow"
            style={{ display: 'inline-block' }}
            authToken={authToken}>
            {' '}
            <button className="primary-button large" type="submit" disabled={isEditing}>
              {t('actions_finish')}
            </button>
          </RailsForm>
        )}
      </div>
    </section>
  )
}

module.exports = WorkflowEdit

class MetadataEditor extends React.Component {
  constructor(props) {
    super(props)
    this.state = { md: this.props.commonMetadata }
    AutoComplete = AutoComplete || require('../../lib/autocomplete.cjsx')
    this.onChangeMdValue = this.onChangeMdValue.bind(this)
    this.onAddMdByMk = this.onAddMdByMk.bind(this)
    this.onRemoveMd = this.onRemoveMd.bind(this)
  }

  onChangeMdValue(name, value) {
    // change value in metadata list where `name` of input matches MetaKey `id`
    this.setState(cur => ({
      md: cur.md.map(md => (md.meta_key.uuid !== name ? md : { ...md, value: f.compact(value) }))
    }))
  }
  onAddMdByMk(mk) {
    // add to metadata list for the MetaKey provided by the automcomplete/searcher.
    const alreadyExists = f.any(this.state.md, md => f.get(mk, 'uuid') === md.meta_key.uuid)
    if (alreadyExists) return false
    // debugger // eslint-disable-line no-debugger
    this.setState(cur => ({ md: cur.md.concat([{ meta_key: mk }]) }))
  }
  onRemoveMd(md) {
    // remove from metadata list the entry matching the mMetaKey `id`
    this.setState(cur => ({ md: cur.md.filter(curmd => curmd.meta_key.uuid !== md.meta_key.uuid) }))
  }

  prepareMdValue(value) {
    if (f.has(value, '0.string')) {
      return [value[0].string]
    } else {
      return value
    }
  }

  render({ props, state } = this) {
    const { onSave, onCancel, isSaving } = props
    const langParam = { lang: currentLocale() }

    return (
      <div>
        {!!isSaving && <SaveBusySignal />}
        <form
          className={isSaving ? 'hidden' : null}
          onSubmit={e => {
            e.preventDefault()
            onSave(this.state.md)
          }}>
          <ul className="pvs">
            {state.md.map((md, i) => (
              <Let key={i} name={md.meta_key.uuid} inputId={`emk_${md.meta_key.uuid}`}>
                {({ name, inputId }) => (
                  <li className="ui-form-group pan pts columned">
                    <div className="form-label">
                      <label htmlFor={inputId}>{md.meta_key.label}</label>
                      <button
                        type="button"
                        className="button small db"
                        onClick={() => this.onRemoveMd(md)}>
                        DEL
                      </button>
                    </div>
                    <InputMetaDatum
                      id={inputId}
                      metaKey={md.meta_key}
                      // NOTE: with plural values this array around value should be removed
                      model={{ values: this.prepareMdValue(md.value) }}
                      name={name}
                      onChange={val => this.onChangeMdValue(name, val)}
                    />
                  </li>
                )}
              </Let>
            ))}
          </ul>
          <div>
            {t('add_md_by_metakey')}
            <span style={{ position: 'relative' }}>
              <AutoComplete
                className="block"
                name="add-meta-key"
                resourceType="MetaKeys"
                searchParams={langParam}
                onSelect={this.onAddMdByMk}
                existingValueHint={t('adder_meta_key_already_used')}
                valueFilter={val => f.any(state.md, md => f.get(val, 'uuid') === md.meta_key.uuid)}
              />
            </span>
          </div>

          <div className="pts pbs">
            <button type="submit" className="button primary-button">
              SAVE
            </button>{' '}
            <button type="button" className="button" onClick={onCancel}>
              CANCEL
            </button>
          </div>
        </form>
        {!!DEBUG_STATE && <ShowJSONData data={{ state, props }} />}
      </div>
    )
  }
}

class PermissionsEditor extends React.Component {
  constructor(props) {
    super(props)
    this.state = { ...this.props.commonPermissions }
    AutoComplete = AutoComplete || require('../../lib/autocomplete.cjsx')
    this.onSetResponsible = this.onSetResponsible.bind(this)
    this.onRemoveResponsible = this.onRemoveResponsible.bind(this)
    this.onTogglePublicRead = this.onTogglePublicRead.bind(this)
    this.onAddPermissionEntity = this.onAddPermissionEntity.bind(this)
    this.onRemovePermissionEntity = this.onRemovePermissionEntity.bind(this)
  }

  onSetResponsible(obj) {
    this.setState({ responsible: obj })
  }

  onRemoveResponsible() {
    this.setState({ responsible: null })
  }

  onTogglePublicRead() {
    this.setState(cur => ({ read_public: !cur.read_public }))
  }

  onAddPermissionEntity(listKey, obj) {
    this.setState(cur => ({ [listKey]: cur[listKey].concat(obj) }))
  }

  onRemovePermissionEntity(listKey, obj) {
    this.setState(cur => ({ [listKey]: cur[listKey].filter(item => item.uuid !== obj.uuid) }))
  }

  render({ props, state } = this) {
    const { onSave, onCancel, isSaving } = props

    return (
      <div>
        {!!isSaving && <SaveBusySignal />}
        <form
          className={isSaving ? 'hidden' : null}
          onSubmit={e => {
            e.preventDefault()
            onSave(this.state)
          }}>
          <ul>
            <li>
              <span className="title-s">{t('common_settings_permissions_responsible')}: </span>
              <UI.TagCloud
                mod="person"
                mods="small inline"
                list={labelize([state.responsible], {
                  onDelete: this.onRemoveResponsible
                })} />
              <div className="row">
                <div className="col1of3">
                  {t('common_settings_permissions_select_user')}:{' '}
                  <AutocompleteAdder
                    type="Users"
                    onSelect={this.onSetResponsible}
                    valueFilter={val => f.get(state.responsible, 'uuid') === f.get(val, 'uuid')}
                  />
                </div>
              </div>
            </li>
            <li>
              <span className="title-s">
                {t('common_settings_permissions_write')}
                {': '}
              </span>
              <UI.TagCloud
                mod="person"
                mods="small inline"
                list={labelize(state.write, {
                  onDelete: f.curry(this.onRemovePermissionEntity)('write')
                })}
              />
              <MultiAdder onAdd={f.curry(this.onAddPermissionEntity)('write')} permissionsScope='write' />
            </li>
            <li>
              <span className="title-s">
                {t('common_settings_permissions_read')}
                {': '}
              </span>
              <UI.TagCloud
                mod="person"
                mods="small inline"
                list={labelize(state.read, {
                  onDelete: f.curry(this.onRemovePermissionEntity)('read')
                })} />
              <MultiAdder onAdd={f.curry(this.onAddPermissionEntity)('read')} permissionsScope='read' />
            </li>
            <li>
              <span className="title-s">
                {t('common_settings_permissions_read_public')}
                {': '}
              </span>
              <input
                type="checkbox"
                checked={state.read_public}
                onChange={this.onTogglePublicRead}
              />
            </li>
          </ul>

          <div className="pts pbs">
            <button type="submit" className="button primary-button">
              SAVE
            </button>{' '}
            <button type="button" className="button" onClick={onCancel}>
              CANCEL
            </button>
          </div>
        </form>
        {!!DEBUG_STATE && <ShowJSONData data={{ state, props }} />}
      </div>
    )
  }
}

class NameEditor extends React.Component {
  constructor(props) {
    super(props)
    this.state = { name: this.props.name }
    this.onSetName = this.onSetName.bind(this)
  }

  onSetName({ target }) {
    this.setState({ name: target.value })
  }

  render({ props, state } = this) {
    const { onSave, onCancel, isSaving } = props
    // like .title-l class:
    const inputStyle = { fontSize: '17px', fontWeight: '700' }

    return (
      <div className="pts">
        {!!isSaving && <SaveBusySignal />}
        <form
          className={isSaving ? 'hidden' : null}
          onSubmit={e => {
            e.preventDefault()
            onSave(this.state.name)
          }}>
          <input
            type="text"
            className="block"
            value={state.name}
            onChange={this.onSetName}
            style={inputStyle}
          />

          <div className="pts pbs">
            <button type="submit" className="button primary-button">
              SAVE
            </button>{' '}
            <button type="button" className="button" onClick={onCancel}>
              CANCEL
            </button>
          </div>
        </form>
        {!!DEBUG_STATE && <ShowJSONData data={{ state, props }} />}
      </div>
    )
  }
}

class OwnersEditor extends React.Component {
  constructor(props) {
    super(props)
    this.state = { owners: this.props.workflowOwners }
    AutoComplete = AutoComplete || require('../../lib/autocomplete.cjsx')
    this.onAddOwner = this.onAddOwner.bind(this)
    this.onRemoveOwner = this.onRemoveOwner.bind(this)
  }

  onAddOwner(owner) {
    this.setState(cur => ({ owners: f.uniq(cur.owners.concat(owner), 'uuid') }))
  }

  onRemoveOwner(owner) {
    this.setState(cur => ({ owners: cur.owners.filter(item => item.uuid !== owner.uuid) }))
  }

  render({ props, state } = this) {
    return (
      <div>
        {!!props.isSaving && <SaveBusySignal />}
        <form onSubmit={(e) => { e.preventDefault(); props.onSave(state.owners) }}>
          <UI.TagCloud
            mod="person"
            mods="small"
            list={labelize(this.state.owners, {
              onDelete: this.onRemoveOwner,
              creatorId: props.creator.uuid
            })}
          />
          <div className="row">
            <div className="col1of3">
              {t('common_settings_permissions_select_user')}:{' '}
              <AutocompleteAdder
                type="Users"
                onSelect={this.onAddOwner}
                valueFilter={({ uuid }) => f.includes(f.map(this.state.owners, 'uuid'), uuid) }
              />
            </div>
          </div>
          <div className="pts pbs">
            <button type="submit" className="button primary-button">
              SAVE
            </button>{' '}
            <button type="button" className="button" onClick={props.onCancel}>
              CANCEL
            </button>
          </div>
        </form>
      </div>
    )
  }
}

const Explainer = ({ children }) => (
  <p className="paragraph-s mts measure-wide" style={{ fontStyle: 'italic' }}>
    {children}
  </p>
)

const EditButton = ({ onClick, icon = 'icon-pen', ...props }) => {
  return (
    <button
      {...props}
      onClick={onClick}
      style={{ background: 'transparent', WebkitAppearance: 'none' }}>
      <small className="link">{!f.isEmpty(icon) && <i className={icon} />}</small>
    </button>
  )
}

const PreviewButton = ({ handleClick, canPreview, isEditing, isPreviewing, previewUrl }) => {
  const cssClasses = cx('primary-button large', { disabled: isEditing || isPreviewing })
  const disabledButton = <div className={cssClasses}>
    {isPreviewing ? t('actions_validating') : t('actions_validate')}
  </div>
  const regularButton = <a className={cssClasses} href={previewUrl} onClick={handleClick}>
    {t('actions_validate')}
  </a>

  return (
    canPreview && (
      (isEditing || isPreviewing) ? (
        disabledButton
      ) : (
        regularButton
      )
    )
  )
}

const AutocompleteAdder = ({ type, currentValues, ...props }) => {
  const valueFilter = props.valueFilter || (
    ({ uuid }) => f.includes(f.map(currentValues, 'subject.uuid'), uuid)
  )
  return (
    <span style={{ position: 'relative' }}>
      <AutoComplete
        className="block"
        name="autocompleter"
        {...props}
        resourceType={type}
        valueFilter={valueFilter}
      />
    </span>
  )
}

const MultiAdder = ({ currentUsers, currentGroups, currentApiClients, onAdd , permissionsScope }) => (
  <div className="row pts pbm">
    <div className="col1of3">
      <div className="">
        {t('common_settings_permissions_add_user')}:{' '}
        <AutocompleteAdder type="Users" onSelect={onAdd} currentValues={currentUsers} />
      </div>
    </div>
    <div className="col1of3">
      <div className="pls">
        {t('common_settings_permissions_add_group')}:{' '}
        <AutocompleteAdder
          type="Groups"
          searchParams={{ scope: 'permissions' }}
          onSelect={onAdd}
          currentValues={currentGroups}
        />
      </div>
    </div>
    { permissionsScope === 'read' &&
      <div className="col1of3">
        <div className="pls">
          {t('common_settings_permissions_add_api_client')}:{' '}
          <AutocompleteAdder type="ApiClients" onSelect={onAdd} currentValues={currentApiClients} />
        </div>
      </div>
    }
  </div>
)

const SaveBusySignal = () => (
  <div className="pal" style={{ textAlign: 'center' }}>
    {'Saving…'}
  </div>
)

const ShowJSONData = ({ data }) => (
  <div>
    <hr />
    <pre className="mas pam code">{JSON.stringify(data, 0, 2)}</pre>
  </div>
)

const Let = ({ children, ...bindings }) => children(bindings)
