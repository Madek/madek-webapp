/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Permissions Form for single or batch resources

import React from 'react'
import PropTypes from 'prop-types'
import t from '../../lib/i18n-translate.js'
import { present, omit, isArray, isBoolean, curry } from '../../lib/utils.js'
import Icon from '../ui-components/Icon.jsx'
import Tooltipped from '../ui-components/Tooltipped.jsx'

// NOTE: used for static (server-side) rendering (state.editing = false)
let AutoComplete = null // only required client-side!

// Subject Decorators (overidable by props for custom render)
const defaultSubjectDecos = {
  User({ subject }) {
    return <span className="text">{subject.name}</span>
  },

  Group({ subject }) {
    return <span className="text">{subject.detailed_name}</span>
  },

  ApiClient({ subject }) {
    return <span className="text">{subject.login}</span>
  },

  Public({ subject }) {
    return <span>{subject}</span>
  }
}

const doOptionalsInclude = function (optionals, type) {
  const types = isArray(type) ? type : [type]
  return types.some(t => optionals.includes(t))
}

class ResourcePermissionsForm extends React.Component {
  static defaultProps = {
    children: null,
    onSubmit() {}, // noop
    decos: defaultSubjectDecos,
    optionals: ['ApiClients']
  }

  constructor(props) {
    super(props)
    this._isMounted = false
  }

  // this will only ever run on the client:
  componentDidMount() {
    this._isMounted = true
    // init autocompletes, then force re-render:
    AutoComplete = require('../lib/autocomplete.jsx').default
    if (this._isMounted) {
      return this.forceUpdate()
    }
  }

  componentWillUnmount() {
    return (this._isMounted = false)
  }

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, children, editing, saving, onEdit, onSubmit, onCancel, optionals, decos } = param
    const editable = get.can_edit
    const user_permissions_title =
      get.type === 'Vocabulary'
        ? t('permission_subject_title_users')
        : t('permission_subject_title_users_or_delegations')

    const { onPermissionChange, onPublicPermissionChange, onAddSubject, onRemoveSubject } = param

    let rows = [
      {
        // User permissions
        collectionKey: 'user_permissions',
        isSubjectList: true,
        type: ['Users', 'Delegations'],
        title: user_permissions_title,
        icon: 'privacy-private-alt',
        SubjectDeco: decos.Users || defaultSubjectDecos.User,
        permissionsList: get.user_permissions,
        overriddenBy: get.public_permission
      },
      {
        // Groups permissions
        collectionKey: 'group_permissions',
        isSubjectList: true,
        type: 'Groups',
        title: t('permission_subject_title_groups'),
        icon: 'privacy-group-alt',
        SubjectDeco: decos.Groups || defaultSubjectDecos.Group,
        permissionsList: get.group_permissions,
        overriddenBy: get.public_permission,
        searchParams: { scope: 'permissions' }
      },
      {
        // ApiApp permissions
        collectionKey: 'api_client_permissions',
        isSubjectList: true,
        type: 'ApiClients',
        title: t('permission_subject_title_apiapps'),
        icon: 'api',
        SubjectDeco: decos.ApiClients || defaultSubjectDecos.ApiClient,
        permissionsList: get.api_client_permissions,
        overriddenBy: get.public_permission
      },

      // Public permissions
      {
        collectionKey: null,
        isSubjectList: false,
        title: t('permission_subject_title_public'),
        subjectName: t('permission_subject_name_public'),
        icon: 'privacy-open',
        SubjectDeco: decos.Public || defaultSubjectDecos.Public,
        permissionsList: [get.public_permission],
        permissionTypes: get.permission_types
      }
    ]
    rows = rows.filter(
      ({ type, permissionsList }) =>
        // optionals: hidden on show if empty; always visible on edit
        !(!editing && type && doOptionalsInclude(optionals, type) && permissionsList.length < 1)
    )

    return (
      <form name="ui-rights-management" onSubmit={onSubmit}>
        {children}
        <div className="ui-rights-management">
          {rows.map(function (row, i) {
            const showTitles = i === 0 // show titles on first table only
            return (
              <PermissionsBySubjectType
                key={i}
                {...Object.assign({}, row, {
                  showTitles: showTitles,
                  editing: editing,
                  permissionTypes: get.permission_types,
                  onPermissionChange: row.collectionKey ? onPermissionChange : onPublicPermissionChange,
                  onAddSubject: onAddSubject,
                  onRemoveSubject: onRemoveSubject
                })}
              />
            )
          })}
        </div>
        <div className="ptl">
          <div className="form-footer">
            {editable && onEdit && !editing && (
              <div className="ui-actions">
                <a href={this.props.editUrl} onClick={onEdit} className="primary-button large">
                  {t('permissions_table_edit_btn')}
                </a>
              </div>
            )}
            {editing && (onCancel || onSubmit) && (
              <div className="ui-actions">
                {onCancel ? (
                  <a className="link weak" href={get.url} onClick={onCancel}>
                    {t('permissions_table_cancel_btn')}
                  </a>
                ) : undefined}
                {onSubmit ? (
                  <button className="primary-button large" disabled={saving}>
                    {t('permissions_table_save_btn')}
                  </button>
                ) : undefined}
              </div>
            )}
          </div>
        </div>
      </form>
    )
  }
}

class PermissionsBySubjectType extends React.Component {
  constructor(props) {
    super(props)
    this.onAddSubject = this.onAddSubject.bind(this)
  }

  onAddSubject(subject) {
    const { permissionsList, collectionKey, onAddSubject } = this.props
    if (onAddSubject) {
      onAddSubject(collectionKey, subject)
    } else {
      // legacy: ampersand collection (BatchResourcePermissions)
      const models = permissionsList.models || permissionsList
      if (models.map(m => m.subject.uuid).includes(subject.uuid)) return
      permissionsList.add({ subject })
    }
  }

  render() {
    const {
      type,
      title,
      icon,
      permissionsList,
      isSubjectList,
      collectionKey,
      SubjectDeco,
      subjectName,
      permissionTypes,
      overriddenBy,
      editing,
      showTitles,
      searchParams,
      onPermissionChange,
      onRemoveSubject
    } = this.props

    // Support both plain arrays (new) and ampersand collections (legacy batch)
    const items = permissionsList
    const existingUuids = () =>
      (permissionsList.models || permissionsList).map(m => m.subject && m.subject.uuid)
    // Show "add subject" row when editing a subject list
    const showAddSubject = editing && (isSubjectList != null ? isSubjectList : permissionsList.isCollection)

    return (
      <div className="ui-rights-management-editing">
        <div className="ui-rights-body">
          <table className="ui-rights-group">
            <PermissionsSubjectHeader
              name={title}
              icon={icon}
              titles={permissionTypes}
              showTitles={!!showTitles}
            />
            <tbody>
              {items.map(function (permissions) {
                const subject = permissions.subject || subjectName
                const tooltipText = permissions.tooltip_text || (subject && subject.tooltip_text)

                const handlePermissionChange = onPermissionChange
                  ? (name, value) => {
                      if (collectionKey) {
                        // subject collection: pass collectionKey + subjectUuid
                        onPermissionChange(collectionKey, subject.uuid, permissionTypes, name, value)
                      } else {
                        // public permission
                        onPermissionChange(permissionTypes, name, value)
                      }
                    }
                  : undefined

                const handleRemove = onRemoveSubject && permissions.subject
                  ? () => onRemoveSubject(collectionKey, permissions.subject.uuid)
                  : undefined

                return (
                  <PermissionsSubject
                    key={(subject && subject.uuid) || 'pub'}
                    permissions={permissions}
                    subject={subject}
                    SubjectDeco={SubjectDeco}
                    overriddenBy={overriddenBy}
                    permissionTypes={permissionTypes}
                    editing={editing}
                    tooltipText={tooltipText}
                    onPermissionChange={handlePermissionChange}
                    onRemoveSubject={handleRemove}
                  />
                )
              })}
            </tbody>
          </table>
          {showAddSubject ? (
            <div className="ui-add-subject ptx">
              <div className="col1of3" style={{ position: 'relative', maxWidth: '300px' }}>
                {type != null && AutoComplete
                  ? React.createElement(AutoComplete, {
                      className: 'block',
                      name: `add_${type}`,
                      resourceType: type,
                      valueFilter({ uuid }) {
                        return existingUuids().includes(uuid)
                      },
                      onSelect: this.onAddSubject,
                      searchParams: searchParams
                    })
                  : undefined}
              </div>
            </div>
          ) : undefined}
        </div>
      </div>
    )
  }
}

class PermissionsSubjectHeader extends React.Component {
  render() {
    const { name, icon, titles, showTitles } = this.props
    return (
      <thead>
        <tr>
          <td className="ui-rights-user-title">
            {name} <i className={`icon-${icon}`} />
          </td>
          {titles.map(name => (
            <td className="ui-rights-check-title" key={name}>
              {showTitles && t(`permission_name_${name}`)}
            </td>
          ))}
        </tr>
      </thead>
    )
  }
}

class PermissionsSubject extends React.Component {
  constructor(props) {
    super(props)
    this.onPermissionChange = this.onPermissionChange.bind(this)
    this.onSubjectRemove = this.onSubjectRemove.bind(this)
  }

  adjustCheckboxesDependingOnStrength(name, stronger) {
    let beforeCurrent = true
    return (() => {
      const result = []
      for (var i in this.props.permissionTypes) {
        var permissionType = this.props.permissionTypes[i]
        var isEnabled = present(this.props.permissions[permissionType])
        var isCurrent = permissionType === name
        if (isCurrent) {
          beforeCurrent = false
        }
        if (!isCurrent && isEnabled) {
          if (beforeCurrent && stronger) {
            this.props.permissions[permissionType] = true
          }
          if (!beforeCurrent && !stronger) {
            result.push((this.props.permissions[permissionType] = false))
          } else {
            result.push(undefined)
          }
        } else {
          result.push(undefined)
        }
      }
      return result
    })()
  }

  setWeakerUnchecked(name) {
    return this.adjustCheckboxesDependingOnStrength(name, true)
  }

  setStrongerChecked(name) {
    return this.adjustCheckboxesDependingOnStrength(name, false)
  }

  onPermissionChange(name, event) {
    const value = event.target.checked
    if (this.props.onPermissionChange) {
      // new pattern: parent holds state, cascade computed there
      this.props.onPermissionChange(name, value)
    } else {
      // legacy: direct mutation for BatchResourcePermissions
      this.props.permissions[name] = value
      if (value === true) {
        this.setWeakerUnchecked(name)
      } else {
        this.setStrongerChecked(name)
      }
    }
  }

  onSubjectRemove() {
    if (this.props.onRemoveSubject) {
      this.props.onRemoveSubject()
    } else {
      // legacy: ampersand destroy for BatchResourcePermissions
      this.props.permissions.destroy()
    }
  }

  render() {
    const {
      permissions,
      overriddenBy,
      subject,
      permissionTypes,
      SubjectDeco,
      editing,
      tooltipText
    } = this.props
    const { onPermissionChange, onSubjectRemove } = this

    return (
      <tr>
        <td className="ui-rights-user">
          {editing && permissions.subject != null ? (
            <RemoveButton onClick={onSubjectRemove} />
          ) : undefined}
          <SubjectDeco subject={subject} />
          {tooltipText && (
            <Tooltipped text={tooltipText} id={'tooltip' + Math.random()}>
              <span className="ui-rights-management__ttip-toggle">
                <Icon i="question" />
              </span>
            </Tooltipped>
          )}
        </td>

        {permissionTypes.map(function (name) {
          const isEnabled = present(permissions[name])
          const curState = permissions[name] // true/false/mixed
          const isOverridden = overriddenBy ? overriddenBy[name] === true : false
          let title = t(`permission_name_${name}`)

          return (
            <td className="ui-rights-check view" key={name}>
              {!isEnabled ? null : ( // leave the field empty if permission is not possible:
                <span className="ui-rights-check-container">
                  {(() => {
                    if (isOverridden) {
                      title += ` ${t('permission_overridden_by_public')}`
                      return <i className="icon-privacy-open" title={title} />
                    }
                  })()}
                  {editing ? (
                    <label className="ui-rights-check-label">
                      <TristateCheckbox
                        checked={curState}
                        onChange={curry(onPermissionChange)(name)}
                        name={name}
                        title={title}
                      />
                    </label>
                  ) : curState === true ? (
                    <i className="icon-checkmark" title={title} />
                  ) : (
                    <span className="pseudo-icon-dash" title={title}>
                      —
                    </span>
                  )}
                </span>
              )}
            </td>
          )
        })}
      </tr>
    )
  }
}

class RemoveButton extends React.Component {
  render() {
    const onClick = this.props.onClick || null
    return (
      <a
        onClick={onClick}
        className="button small ui-rights-remove icon-close small"
        title={t('permissions_table_remove_subject_btn')}
      />
    )
  }
}

class TristateCheckbox extends React.Component {
  static propTypes = { checked: PropTypes.oneOf([true, false, 'mixed']) }

  static defaultProps = {
    onChange() {} // noop
  }

  constructor(props) {
    super(props)
    this._inputNode = null
  }

  // NOTE: 'indeterminate' is a node attribute (not a prop!),
  // need to set on mount and every re-render!!
  _setIndeterminate() {
    const isMixed = !isBoolean(this.props.checked)
    if (this._inputNode) {
      // <- only if it's mounted…
      return (this._inputNode.indeterminate = isMixed)
    }
  }

  componentDidUpdate() {
    return this._setIndeterminate()
  }

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    const restProps = omit(props, ['checked'])
    const isMixed = !isBoolean(props.checked)
    return (
      <input
        {...Object.assign({ type: 'checkbox' }, restProps, {
          checked: isMixed ? false : props.checked,
          ref: inputNode => {
            this._inputNode = inputNode
            return this._setIndeterminate()
          }
        })}
      />
    )
  }
}

export default ResourcePermissionsForm
