import React from 'react'
import f from 'active-lodash'
import cx from 'classnames'
import currentLocale from '../../../lib/current-locale'
import UI from '../../ui-components/index.js'
import SubSection from '../../ui-components/SubSection'
import ResourceThumbnail from '../../decorators/ResourceThumbnail.jsx'
import InputMetaDatum from '../../decorators/InputMetaDatum.jsx'
import WorkflowCommonPermissions from '../../decorators/WorkflowCommonPermissions'
import RailsForm from '../../lib/forms/rails-form.jsx'
import appRequest from '../../../lib/app-request.js'
import { Let, IfLet } from '../../lib/lets'
import I18nTranslate from '../../../lib/i18n-translate'
import labelize from '../../../lib/labelize'
let AutoComplete = false // client-side only!
const t = I18nTranslate

const DEBUG_STATE = false // set to true when developing or debugging forms with state!
const HIDE_OVERRIDABLE_TOGGLE = true

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
        owners: f.map(owners, o => f.pick(o, ['uuid', 'type']))
      }
    }

    appRequest({ url: action.url, method: action.method, json: body }, (err, res) => {
      if (err) {
        console.error(err)
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ ...finalState, ownersUpdateError: err })
      }
      DEBUG_STATE && console.log({ res })
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
      const { uuid, type } = obj
      return { uuid, type }
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
        console.error(err)
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ ...finalState, permissionsUpdateError: err })
      }
      DEBUG_STATE && console.log({ res })
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
          value: f.map(md.value, prepareValue),
          is_common: md.is_common,
          is_mandatory: md.is_mandatory,
          is_overridable: md.is_overridable
        }))
      }
    }

    appRequest({ url: action.url, method: action.method, json: body }, (err, res) => {
      if (err) {
        console.error(err)
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ finalState, metaDataUpdateError: err })
      }
      DEBUG_STATE && console.log({ res })
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
        console.error(err)
        alert('ERROR! ' + JSON.stringify(err))
        return this.setState({ finalState, metaDataUpdateError: err })
      }
      DEBUG_STATE && console.log({ res })
      this.setState({ ...finalState, name: f.get(res, 'body.name') })
    })
  }

  handleFillDataClick(e) {
    if (this.state.isProcessing) {
      e.preventDefault()
    }
    this.setState({ isProcessing: true })
  }

  handlePreviewClick() {
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
  // status,
  authToken,

  get,

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
        <span style={supHeadStyle}>{t('workflow_feature_title')}</span>
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
            {t('workflow_associated_collections_title')}
          </SubSection.Title>

          <Explainer>{t('workflow_associated_collections_explain')}</Explainer>

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
                    <i className="icon-upload" />
                  </span>{' '}
                  {t('workflow_associated_collections_upload')}
                </a>
              </div>
            )}
          </div>
        </SubSection>

        <SubSection>
          <SubSection.Title tag="h2" className="title-m mts">
            {t('workflow_owners_title')}{' '}
            {canEditOwners && !isEditingOwners && <EditButton onClick={onToggleEditOwners} />}
          </SubSection.Title>
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
            {t('workflow_common_settings_title')}
          </SubSection.Title>

          <Explainer>{t('workflow_common_settings_explain')}</Explainer>

          <h3 className="title-s mts">
            {t('workflow_common_settings_permissions_title')}
            {'  '}
            {!isEditingPermissions && canEdit && <EditButton onClick={onToggleEditPermissions} />}
          </h3>

          <IfLet txt={t('workflow_common_settings_explain_permissions')}>
            {txt => <Explainer className="mbs">{txt}</Explainer>}
          </IfLet>

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

          <Explainer>{t('workflow_common_settings_permissions_hint_after')}</Explainer>

          <h3 className="title-s mts">
            {t('workflow_common_settings_metadata_title')}
            {'  '}
            {!isEditingMetadata && canEdit && <EditButton onClick={onToggleEditMetadata} />}
          </h3>

          <Explainer className="mbs">
            {t('workflow_common_settings_explain_metadata')}
            <br />
            {t('workflow_common_settings_explain_metadata2')}
          </Explainer>

          {isEditingMetadata ? (
            <MetadataEditor
              key={isEditingMetadata}
              commonMetadata={commonMetadata}
              isSaving={isSavingMetadata}
              onCancel={onToggleEditMetadata}
              onSave={onSaveMetadata}
            />
          ) : (
            <Let
              firstColStyle={{ width: '18rem' }}
              problems={f.filter(commonMetadata, md => !!md.problem)}>
              {({ firstColStyle, problems }) => (
                <div>
                  <table>
                    <thead>
                      <tr>
                        <th className="prs" style={firstColStyle}>
                          MetaKey
                        </th>
                        <th className="prs">{t('workflow_md_edit_is_mandatory')}</th>
                        <th className="prs">{t('workflow_md_edit_value')}</th>
                        <th className="pls">{t('workflow_md_edit_scope')}</th>
                      </tr>
                    </thead>
                    <tbody>
                      {commonMetadata.map(
                        ({
                          meta_key,
                          value,
                          is_common,
                          is_mandatory,
                          problem /*, is_overridable*/
                        }) => {
                          if (problem) return false

                          const decoValues = f.isEmpty(value) ? (
                            false
                          ) : f.has(value, '0.string') ? (
                            value[0].string
                          ) : (
                            <UI.TagCloud mods="small inline" list={labelize(value)} />
                          )

                          const hasValueError =
                            is_common && is_mandatory && !isNonEmptyMetaDatumValue(value)

                          return (
                            <tr key={meta_key.uuid}>
                              <th className="prs" style={firstColStyle}>
                                <span title={meta_key.uuid}>{meta_key.label}</span>
                              </th>
                              <th className="prs text-center">
                                {is_mandatory ? (
                                  <UI.Icon i="checkmark" title="Pflichtfeld" />
                                ) : (
                                  <UI.Icon i="close" />
                                )}
                              </th>
                              <th
                                className={cx('prs', {
                                  'bg-error text-error pls ': hasValueError
                                })}>
                                {is_common ? (
                                  decoValues ? (
                                    <details>
                                      <summary className="font-italic">
                                        {t('workflow_md_edit_is_common')}
                                        <b>{t('workflow_md_edit_is_common_nonempty')}</b>
                                      </summary>
                                      {decoValues}
                                    </details>
                                  ) : (
                                    <div>
                                      {hasValueError && (
                                        <UI.Icon
                                          i="bang"
                                          title={t('workflow_md_edit_value_error_notice')}
                                          className="prs"
                                        />
                                      )}
                                      <em className="font-italic">
                                        {t('workflow_md_edit_is_common')}
                                        <b>{t('workflow_md_edit_is_common_empty')}</b>
                                      </em>
                                    </div>
                                  )
                                ) : (
                                  <em className="font-italic">
                                    {t('workflow_md_edit_is_not_common')}
                                  </em>
                                )}
                              </th>
                              <th className="pls">
                                {f.compact(
                                  f
                                    .map(meta_key.scope, str =>
                                      str === 'Entries'
                                        ? t('workflow_md_edit_scope_entry')
                                        : str === 'Sets'
                                          ? t('workflow_md_edit_scope_set')
                                          : false
                                    )
                                    .join(' & ')
                                )}
                              </th>
                            </tr>
                          )
                        }
                      )}
                    </tbody>
                  </table>
                  {!f.isEmpty(problems) && (
                    <div>
                      <b style={{ fontWeight: 'bold' }}>Probleme:</b>

                      {f.map(f.groupBy(problems, 'problem'), (items, problem) => {
                        const problemLabel =
                          problem === 'NOT_FOUND'
                            ? t('workflow_mk_error_not_found')
                            : problem === 'NOT_AUTHORIZED'
                              ? t('workflow_mk_error_not_authorized')
                              : t('workflow_mk_error_unknown')

                        return (
                          <div key={problem}>
                            <em style={{ fontStyle: 'italic' }}>{problemLabel}</em>
                            <br />
                            <code>{f.map(items, 'meta_key.uuid').join(', ')}</code>
                          </div>
                        )
                      })}
                    </div>
                  )}
                </div>
              )}
            </Let>
          )}
        </SubSection>
      </div>

      {!(isEditingPermissions || isEditingMetadata) && (
        <div className="ui-actions phl pbl mtl">
          <a className="link weak" href={get.actions.index.url}>
            {t('workflow_actions_back')}
          </a>
          {canPreview && (
            <a
              className={cx('button large', {
                disabled: isProcessing
              })}
              href={get.actions.fill_data.url}
              onClick={handleFillDataClick}>
              {isProcessing
                ? t('workflow_edit_actions_processing')
                : t('workflow_edit_actions_fill_data')}
            </a>
          )}
          <PreviewButton
            canPreview={canPreview}
            isEditing={isEditing}
            isPreviewing={isPreviewing}
            previewUrl={get.actions.preview.url}
            handleClick={handlePreviewClick}
          />
          {/*
        <button className="tertiary-button large" type="button">
          {t('workflow_actions_validate')}
        </button>
        */}
          {/* eslint-disable-next-line */}
          {canEdit && false && (
            <RailsForm
              action={get.actions.preview.url}
              method={get.actions.preview.method}
              name="workflow"
              style={{ display: 'inline-block' }}
              authToken={authToken}>
              {' '}
              <button className="primary-button large" type="submit" disabled={isEditing}>
                {t('workflow_actions_finish')}
              </button>
            </RailsForm>
          )}
        </div>
      )}
    </section>
  )
}

module.exports = WorkflowEdit

class MetadataEditor extends React.Component {
  constructor(props) {
    super(props)
    this.state = { md: this.props.commonMetadata }
    AutoComplete = AutoComplete || require('../../lib/autocomplete.js')
    this.onChangeMdAttr = this.onChangeMdAttr.bind(this)
    this.onAddMdByMk = this.onAddMdByMk.bind(this)
    this.onRemoveMd = this.onRemoveMd.bind(this)
  }
  onChangeMdAttr(name, attr, val) {
    // change attribute in metadata list where `name` of input matches MetaKey `id`
    this.setState(cur => ({
      md: cur.md.map(md => (md.meta_key.uuid !== name ? md : { ...md, [attr]: val }))
    }))
  }
  onAddMdByMk(mk) {
    // add to metadata list for the MetaKey provided by the automcomplete/searcher.
    const alreadyExists = f.any(this.state.md, md => f.get(mk, 'uuid') === md.meta_key.uuid)
    if (alreadyExists) return false
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

    const legendExplains = [
      [t('workflow_md_edit_is_common'), t('workflow_md_edit_is_common_explanation')],
      [t('workflow_md_edit_is_mandatory'), t('workflow_md_edit_is_mandatory_explanation')],
      [t('workflow_md_edit_remove_btn'), t('workflow_md_edit_remove_explain')]
    ]

    return (
      <div>
        {!!isSaving && <SaveBusySignal />}
        <form
          className={isSaving ? 'hidden' : null}
          onSubmit={e => {
            e.preventDefault()
            onSave(state.md)
          }}>
          <div>
            <dl className="measure-wide">
              <span className="font-italic">{t('workflow_md_edit_legend')}</span>
              {f.flatten(
                f.map(legendExplains, ([dt, dd], i) => [
                  <dt key={'t' + i} className="font-bold">
                    {dt}
                  </dt>,
                  <dd key={'d' + i} className="font-italic plm">
                    {dd}
                  </dd>
                ])
              )}
            </dl>
          </div>
          <div className="pvs" style={{ marginLeft: '-10px' }}>
            {state.md.map((md, i) => (
              <Let
                key={i}
                name={md.meta_key.uuid}
                inputId={`emk_${md.meta_key.uuid}`}
                mkLabel={f.presence(md.meta_key.label)}
                mkNiceUUID={md.meta_key.uuid.split(':').join(':\u200B')}
                mdValue={this.prepareMdValue(md.value)}
                mkdValueError={
                  md.is_common &&
                  md.is_mandatory &&
                  !isNonEmptyMetaDatumValue(this.prepareMdValue(md.value))
                }
                problemDesc={
                  md.problem === 'NOT_FOUND'
                    ? t('workflow_md_edit_mk_error_not_found')
                    : md.problem === 'NOT_AUTHORIZED'
                      ? t('workflow_md_edit_mk_error_not_authorized')
                      : false
                }>
                {({ name, inputId, mkLabel, mkNiceUUID, mdValue, mkdValueError, problemDesc }) => (
                  <div
                    className={cx('ui-form-group  pvs columned', {
                      error: md.problem || mkdValueError
                    })}>
                    {problemDesc && <p className="text-error mbs">{problemDesc}</p>}
                    {mkdValueError && (
                      <p className="text-error mbs">{t('workflow_md_edit_value_error_notice')}</p>
                    )}

                    <div className="form-label">
                      <label htmlFor={inputId}>{mkLabel || mkNiceUUID}</label>
                      {!!mkLabel && (
                        <span style={{ fontWeight: 'normal', display: 'block' }}>
                          <small>({mkNiceUUID})</small>
                        </span>
                      )}
                      <div className="mts">
                        <button
                          type="button"
                          className="button small db mts"
                          onClick={() => this.onRemoveMd(md)}>
                          {t('workflow_md_edit_remove_btn')}
                        </button>{' '}
                      </div>
                    </div>

                    <div className="form-item">
                      <div className={cx('mbs', !!md.is_common && 'separated pbs')}>
                        <label>
                          <input
                            type="checkbox"
                            name="is_common"
                            checked={!!md.is_common}
                            onChange={e =>
                              this.onChangeMdAttr(name, 'is_common', f.get(e, 'target.checked'))
                            }
                          />{' '}
                          {t('workflow_md_edit_is_common')}
                        </label>
                        <br />
                        {!HIDE_OVERRIDABLE_TOGGLE && (
                          <div>
                            <label>
                              <input
                                type="checkbox"
                                name="is_overridable"
                                checked={!!md.is_overridable}
                                onChange={e =>
                                  this.onChangeMdAttr(
                                    name,
                                    'is_overridable',
                                    f.get(e, 'target.checked')
                                  )
                                }
                              />{' '}
                              {t('workflow_md_edit_is_overridable')}
                            </label>
                            <br />
                          </div>
                        )}
                        <label>
                          <input
                            type="checkbox"
                            name="is_mandatory"
                            checked={!!md.is_mandatory}
                            onChange={e =>
                              this.onChangeMdAttr(name, 'is_mandatory', f.get(e, 'target.checked'))
                            }
                          />{' '}
                          {t('workflow_md_edit_is_mandatory')}
                        </label>
                      </div>

                      {!!md.is_common && (
                        <fieldset title="wert">
                          <legend className="font-italic">Fixen Wert vergeben:</legend>
                          <InputMetaDatum
                            key="item"
                            id={inputId}
                            metaKey={md.meta_key}
                            // NOTE: with plural values this array around value should be removed
                            model={{ values: mdValue }}
                            name={name}
                            onChange={val => this.onChangeMdAttr(name, 'value', f.compact(val))}
                          />
                        </fieldset>
                      )}
                    </div>
                  </div>
                )}
              </Let>
            ))}
          </div>

          <div>
            {t('workflow_add_md_by_metakey')}
            <AutoComplete
              className="block mbs"
              name="add-meta-key"
              resourceType="MetaKeys"
              searchParams={langParam}
              onSelect={this.onAddMdByMk}
              existingValueHint={t('workflow_adder_meta_key_already_used')}
              valueFilter={val => f.any(state.md, md => f.get(val, 'uuid') === md.meta_key.uuid)}
            />
          </div>

          <div className="pts pbs">
            <button type="submit" className="button primary-button">
              {t('workflow_edit_actions_save_data')}
            </button>{' '}
            <button type="button" className="button" onClick={onCancel}>
              {t('workflow_edit_actions_cancel')}
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
    AutoComplete = AutoComplete || require('../../lib/autocomplete.js')
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
              <span className="title-s">
                {t('workflow_common_settings_permissions_responsible')}:{' '}
              </span>
              <UI.TagCloud
                mod="person"
                mods="small inline"
                list={labelize([state.responsible], {
                  onDelete: this.onRemoveResponsible
                })}
              />
              <div className="row">
                <div className="col1of3">
                  {t('workflow_common_settings_permissions_select_user')}:{' '}
                  <AutocompleteAdder
                    type={['Delegations', 'Users']}
                    onSelect={this.onSetResponsible}
                    valueFilter={val => f.get(state.responsible, 'uuid') === f.get(val, 'uuid')}
                  />
                </div>
              </div>
            </li>
            <li>
              <span className="title-s">
                {t('workflow_common_settings_permissions_write')}
                {': '}
              </span>
              <UI.TagCloud
                mod="person"
                mods="small inline"
                list={labelize(state.write, {
                  onDelete: f.curry(this.onRemovePermissionEntity)('write')
                })}
              />
              <MultiAdder
                onAdd={f.curry(this.onAddPermissionEntity)('write')}
                permissionsScope="write"
              />
            </li>
            <li>
              <span className="title-s">
                {t('workflow_common_settings_permissions_read')}
                {': '}
              </span>
              <UI.TagCloud
                mod="person"
                mods="small inline"
                list={labelize(state.read, {
                  onDelete: f.curry(this.onRemovePermissionEntity)('read')
                })}
              />
              <MultiAdder
                onAdd={f.curry(this.onAddPermissionEntity)('read')}
                permissionsScope="read"
              />
            </li>
            <li>
              <span className="title-s">
                {t('workflow_common_settings_permissions_read_public')}
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
              {t('workflow_edit_actions_save_data')}
            </button>{' '}
            <button type="button" className="button" onClick={onCancel}>
              {t('workflow_edit_actions_cancel')}
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
              {t('workflow_edit_actions_save_data')}
            </button>{' '}
            <button type="button" className="button" onClick={onCancel}>
              {t('workflow_edit_actions_cancel')}
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
    AutoComplete = AutoComplete || require('../../lib/autocomplete.js')
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
        <form
          onSubmit={e => {
            e.preventDefault()
            props.onSave(state.owners)
          }}>
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
              {t('workflow_common_settings_permissions_select_owner')}:{' '}
              <AutocompleteAdder
                type={['Delegations', 'Users']}
                onSelect={this.onAddOwner}
                valueFilter={({ uuid }) => f.includes(f.map(this.state.owners, 'uuid'), uuid)}
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

const Explainer = ({ className, children }) => (
  <p className={cx('paragraph-s mts measure-wide', className)} style={{ fontStyle: 'italic' }}>
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
  const disabledButton = (
    <div className={cssClasses}>
      {isPreviewing ? t('workflow_actions_validating') : t('workflow_actions_validate')}
    </div>
  )
  const regularButton = (
    <a className={cssClasses} href={previewUrl} onClick={handleClick}>
      {t('workflow_actions_validate')}
    </a>
  )

  return canPreview && (isEditing || isPreviewing ? disabledButton : regularButton)
}

const AutocompleteAdder = ({ type, currentValues, ...props }) => {
  const valueFilter =
    props.valueFilter || (({ uuid }) => f.includes(f.map(currentValues, 'subject.uuid'), uuid))
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

const MultiAdder = ({
  currentUsers,
  currentGroups,
  currentApiClients,
  onAdd,
  permissionsScope
}) => (
  <div className="row pts pbm">
    <div className="col1of3">
      <div className="">
        {t('workflow_common_settings_permissions_add_user')}:{' '}
        <AutocompleteAdder type="Users" onSelect={onAdd} currentValues={currentUsers} />
      </div>
    </div>
    <div className="col1of3">
      <div className="pls">
        {t('workflow_common_settings_permissions_add_group')}:{' '}
        <AutocompleteAdder
          type="Groups"
          searchParams={{ scope: 'permissions' }}
          onSelect={onAdd}
          currentValues={currentGroups}
        />
      </div>
    </div>
    {permissionsScope === 'read' && (
      <div className="col1of3">
        <div className="pls">
          {t('workflow_common_settings_permissions_add_api_client')}:{' '}
          <AutocompleteAdder type="ApiClients" onSelect={onAdd} currentValues={currentApiClients} />
        </div>
      </div>
    )}
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

const isNonEmptyMetaDatumValue = val => {
  const isNonEmpty = i => !f.isEmpty(f.isString ? f.trim(i) : i)
  if (!val) return false
  if (f.isArray(val)) return f.any(f.compact(val), isNonEmpty)
  else return isNonEmpty(val)
}
