/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Permissions Form for single or batch resources

const React = require('react')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const ampersandReactMixin = require('ampersand-react-mixin')

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

const doOptionalsInclude = function(optionals, type) {
  const types = f.isArray(type) ? type : [type]
  return f.some(types, t => f.contains(optionals, t))
}

module.exports = React.createClass({
  displayName: 'ResourcePermissionsForm',
  mixins: [ampersandReactMixin],

  getDefaultProps() {
    return {
      children: null,
      onSubmit() {}, // noop
      decos: defaultSubjectDecos,
      optionals: ['ApiClients']
    }
  },

  // this will only ever run on the client:
  componentDidMount() {
    this._isMounted = true
    // init autocompletes, then force re-render:
    AutoComplete = require('../lib/autocomplete.js')
    if (this._isMounted) {
      return this.forceUpdate()
    }
  },

  componentWillUnmount() {
    return (this._isMounted = false)
  },

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

    let rows = [
      {
        // User permissions
        type: ['Users', 'Delegations'],
        title: user_permissions_title,
        icon: 'privacy-private-alt',
        SubjectDeco: decos.Users || defaultSubjectDecos.User,
        permissionsList: get.user_permissions,
        overriddenBy: get.public_permission
      },
      {
        // Groups permissions
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
        type: 'ApiClients',
        title: t('permission_subject_title_apiapps'),
        icon: 'api',
        SubjectDeco: decos.ApiClients || defaultSubjectDecos.ApiClient,
        permissionsList: get.api_client_permissions,
        overriddenBy: get.public_permission
      },

      // Public permissions
      {
        title: t('permission_subject_title_public'),
        subjectName: t('permission_subject_name_public'),
        icon: 'privacy-open',
        SubjectDeco: decos.Public || defaultSubjectDecos.Public,
        permissionsList: [get.public_permission],
        permissionTypes: get.permission_types
      }
    ]
    rows = f.reject(
      rows,
      ({ type, permissionsList }) =>
        // optionals: hidden on show if empty; always visible on edit
        !editing && type && doOptionalsInclude(optionals, type) && permissionsList.length < 1
    )

    return (
      <form name="ui-rights-management" onSubmit={onSubmit}>
        {children}
        <div className="ui-rights-management">
          {rows.map(function(row, i) {
            const showTitles = i === 0 // show titles on first table only
            return (
              <PermissionsBySubjectType
                {...Object.assign({}, row, {
                  key: i,
                  showTitles: showTitles,
                  editing: editing,
                  permissionTypes: get.permission_types
                })}
              />
            )
          })}
        </div>
        <div className="ptl">
          <div className="form-footer">
            {(() => {
              switch (false) {
                case !editable || !!editing:
                  return (
                    <div className="ui-actions">
                      <a
                        href={this.props.editUrl}
                        onClick={onEdit}
                        className="primary-button large">
                        {t('permissions_table_edit_btn')}
                      </a>
                    </div>
                  )
                case !editing || (!onCancel && !onSubmit):
                  return (
                    <div className="ui-actions">
                      {onCancel ? (
                        <a className="link weak" href={get.url} onClick={onCancel}>
                          {t('permissions_table_cancel_btn')}
                        </a>
                      ) : (
                        undefined
                      )}
                      {onSubmit ? (
                        <button className="primary-button large" disabled={saving}>
                          {t('permissions_table_save_btn')}
                        </button>
                      ) : (
                        undefined
                      )}
                    </div>
                  )
              }
            })()}
          </div>
        </div>
      </form>
    )
  }
})

var PermissionsBySubjectType = React.createClass({
  displayName: 'PermissionsBySubjectType',
  mixins: [ampersandReactMixin],

  onAddSubject(subject) {
    const list = this.props.permissionsList
    if (f.includes(f.map(list.models, 'subject.uuid'), subject.uuid)) {
      return
    }
    return list.add({ subject })
  },

  render() {
    let {
      type,
      title,
      icon,
      permissionsList,
      SubjectDeco,
      subjectName,
      permissionTypes,
      overriddenBy,
      editing,
      showTitles,
      searchParams
    } = this.props
    if (!showTitles) {
      showTitles = false
    }

    return (
      <div
        className={
          `ui-rights-management-users${editing}` ? ' ui-rights-management-editing' : undefined
        }>
        <div className="ui-rights-body">
          <table className="ui-rights-group">
            <PermissionsSubjectHeader
              name={title}
              icon={icon}
              titles={permissionTypes}
              showTitles={showTitles}
            />
            <tbody>
              {permissionsList.map(function(permissions) {
                const subject = permissions.subject || subjectName

                return (
                  <PermissionsSubject
                    key={subject.uuid || 'pub'}
                    permissions={permissions}
                    subject={subject}
                    SubjectDeco={SubjectDeco}
                    overriddenBy={overriddenBy}
                    permissionTypes={permissionTypes}
                    editing={editing}
                  />
                )
              })}
            </tbody>
          </table>
          {editing && permissionsList.isCollection ? (
            <div className="ui-add-subject ptx">
              <div className="col1of3" style={{ position: 'relative', maxWidth: '300px' }}>
                {type != null && AutoComplete
                  ? React.createElement(AutoComplete, {
                      className: 'block',
                      name: `add_${type}`,
                      resourceType: type,
                      valueFilter({ uuid }) {
                        return f.includes(f.map(permissionsList.models, 'subject.uuid'), uuid)
                      },
                      onSelect: this.onAddSubject,
                      searchParams: searchParams
                    })
                  : undefined}
              </div>
            </div>
          ) : (
            undefined
          )}
        </div>
      </div>
    )
  }
})

var PermissionsSubjectHeader = React.createClass({
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
})

var PermissionsSubject = React.createClass({
  mixins: [ampersandReactMixin],

  adjustCheckboxesDependingOnStrength(name, stronger) {
    let beforeCurrent = true
    return (() => {
      const result = []
      for (var i in this.props.permissionTypes) {
        var permissionType = this.props.permissionTypes[i]
        var isEnabled = f.present(this.props.permissions[permissionType])
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
  },

  setWeakerUnchecked(name) {
    return this.adjustCheckboxesDependingOnStrength(name, true)
  },

  setStrongerChecked(name) {
    return this.adjustCheckboxesDependingOnStrength(name, false)
  },

  onPermissionChange(name, event) {
    const value = event.target.checked
    this.props.permissions[name] = value
    if (value === true) {
      return this.setWeakerUnchecked(name)
    } else {
      return this.setStrongerChecked(name)
    }
  },

  onSubjectRemove(_event) {
    return this.props.permissions.destroy()
  },

  render() {
    const { permissions, overriddenBy, subject, permissionTypes, SubjectDeco, editing } = this.props
    const { onPermissionChange, onSubjectRemove } = this

    return (
      <tr>
        <td className="ui-rights-user">
          {editing && permissions.subject != null ? (
            <RemoveButton onClick={onSubjectRemove} />
          ) : (
            undefined
          )}
          <SubjectDeco subject={subject} />
        </td>
        {permissionTypes.map(function(name) {
          const isEnabled = f.present(permissions[name])
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
                        onChange={f.curry(onPermissionChange)(name)}
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
})

var RemoveButton = React.createClass({
  render() {
    return (
      <a
        onClick={f(this.props.onClick).presence()}
        className="button small ui-rights-remove icon-close small"
        title={t('permissions_table_remove_subject_btn')}
      />
    )
  }
})

var TristateCheckbox = React.createClass({
  propTypes: { checked: React.PropTypes.oneOf([true, false, 'mixed']) },
  getDefaultProps() {
    return { onChange() {} }
  }, // noop

  // NOTE: 'indeterminate' is a node attribute (not a prop!),
  // need to set on mount and every re-render!!
  _setIndeterminate() {
    const isMixed = !f.isBoolean(this.props.checked)
    if (this._inputNode) {
      // <- only if it's mounted…
      return (this._inputNode.indeterminate = isMixed)
    }
  },
  _inputNode: null,
  componentDidUpdate() {
    return this._setIndeterminate()
  },

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    const restProps = f.omit(props, ['checked'])
    const isMixed = !f.isBoolean(props.checked)
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
})
