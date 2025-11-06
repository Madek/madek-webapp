/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import { t } from '../../lib/ui.js'
import decorateResource from '../decorate-resource-names.js'
import NewPersonWidget from './new-person-widget.jsx'
let AutoComplete = null // only required client-side!

class InputResources extends React.Component {
  static propTypes = {
    name: PropTypes.string.isRequired,
    resourceType: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
    multiple: PropTypes.bool.isRequired,
    extensible: PropTypes.bool, // only for Keywords
    allowedTypes: PropTypes.array, // only for People
    autocompleteConfig: PropTypes.shape({
      minLength: PropTypes.number
    }),
    autoCompleteSuggestionRenderer: PropTypes.func
  }

  constructor(props) {
    super(props)
    this.state = {}
  }

  componentDidMount() {
    const { values, metaKey } = this.props
    AutoComplete = require('../autocomplete.jsx')
    this.setState({
      values, // keep internal state of entered values
      roles: metaKey && metaKey.roles ? [...Array.from(metaKey.roles)] : []
    })
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    if (this.props.values !== nextProps.values) {
      this.setState({ values: nextProps.values })
    }
  }

  _onItemAdd = item => {
    this._adding = true
    const is_duplicate = (() => {
      if (f.present(item.uuid)) {
        return f(this.state.values).map('uuid').includes(item.uuid)
      } else {
        // check for NEW values…
        if (item.type === 'Keyword') {
          return f(this.state.values).map('term').includes(item.term)
        } else if (item.type === 'Person') {
          return f.any(this.state.values, o => f.isEqual(o, item))
        } else {
          throw new Error('Unknown Resource type!')
        }
      }
    })()

    const newValues = this.state.values.concat(item)
    if (!is_duplicate) {
      this.setState({ values: newValues })
      if (this.props.onChange) {
        return this.props.onChange(newValues)
      }
    }
  }

  _onRoleSave = () => {
    let item, itemIndex
    if (!f.present(this.state.selectedRole)) {
      return
    }

    const newValues = this.state.values.slice(0)
    const selectedRole = f.clone(this.state.selectedRole)

    if (this.state.addingRole === true) {
      if (f.has(this.state.editedItem, 'role') && !f.isEmpty(this.state.editedItem.role)) {
        item = f.cloneDeep(this.state.editedItem)
        item.role = selectedRole
        newValues.push(item)
      } else {
        itemIndex = this.state.editedItemIndex
        item = f.cloneDeep(this.state.values[itemIndex])
        item.role = selectedRole
        newValues[itemIndex] = item
      }
    } else if (this.state.editedRole) {
      ;({ itemIndex } = this.state.editedRole)
      item = f.cloneDeep(this.state.values[itemIndex])
      item.role = selectedRole
      newValues[itemIndex] = item
    }

    this.setState({
      values: newValues,
      editedItem: null,
      editedItemIndex: null,
      addingRole: null,
      editedRole: null,
      selectedRole: null
    })

    if (this.props.onChange) {
      return this.props.onChange(newValues)
    }
  }

  _onNewKeyword = term => {
    return this._onItemAdd({ type: 'Keyword', label: term, isNew: true, term })
  }

  _onNewPerson = obj => {
    return this._onItemAdd(f.extend(obj, { type: 'Person', isNew: true }))
  }

  _onItemRemove = (itemIndex, _event) => {
    _event.stopPropagation()
    const newValues = this.state.values.slice(0)
    newValues.splice(itemIndex, 1)
    this.setState({ values: newValues })

    if (this.props.onChange) {
      return this.props.onChange(newValues)
    }
  }

  _onRoleAdd = (index, e) => {
    e.preventDefault()

    const editedItem = this.state.values[index]
    this.setState({ editedItem, editedItemIndex: index, addingRole: true })

    const { refs } = this
    return setTimeout(() => refs.roleSelect.focus(), 100)
  }

  _onRoleEdit = (role, itemIndex, e) => {
    e.preventDefault()

    this.setState({
      editedItem: this.state.values[itemIndex],
      editedRole: { id: role.id, itemIndex },
      selectedRole: role
    })

    const { refs } = this
    return setTimeout(() => refs.roleSelect.focus(), 100)
  }

  _onRoleSelect = role => {
    this.setState({ selectedRole: role })
    return this.refs.saveRoleButton.focus()
  }

  _onNewRole = label => {
    const { roles } = this.state
    // assign existing if one by the same name already exists
    let r = f.find(roles, x => x.label === label)
    if (r) {
      this.setState({ selectedRole: r })
    } else {
      r = { id: undefined, uuid: undefined, label, type: 'Role' }
      this.setState({ selectedRole: r, roles: [r, ...Array.from(roles)] })
    }
    return this.refs.saveRoleButton.focus()
  }

  _onRoleRemove = (itemIndex, e) => {
    e.preventDefault()

    const newValues = this.state.values.slice(0)
    delete newValues[itemIndex].role
    this.setState({ values: newValues })

    if (this.props.onChange) {
      return this.props.onChange(newValues)
    }
  }

  _onRoleCancel = () => {
    return this.setState({
      editedRole: null,
      editedItemIndex: null,
      editedItem: null,
      selectedRole: null
    })
  }

  _handleMoveUp = (itemIndex, e) => {
    let previousItem
    e.preventDefault()

    if ((previousItem = this.state.values[itemIndex - 1])) {
      const editedItem = this.state.values[itemIndex]
      const newValues = this.state.values.slice(0)
      newValues[itemIndex - 1] = f.cloneDeep(editedItem)
      newValues[itemIndex] = f.cloneDeep(previousItem)
      this.setState({ values: newValues })

      if (this.props.onChange) {
        return this.props.onChange(newValues)
      }
    }
  }

  _handleMoveDown = (itemIndex, e) => {
    let nextItem
    e.preventDefault()

    if ((nextItem = this.state.values[itemIndex + 1])) {
      const editedItem = this.state.values[itemIndex]
      const newValues = this.state.values.slice(0)
      newValues[itemIndex + 1] = f.cloneDeep(editedItem)
      newValues[itemIndex] = f.cloneDeep(nextItem)
      this.setState({ values: newValues })

      if (this.props.onChange) {
        return this.props.onChange(newValues)
      }
    }
  }

  componentDidUpdate() {
    if (this._adding) {
      this._adding = false
      if (this.refs.ListAdder) {
        return setTimeout(this.refs.ListAdder.focus, 1)
      }
    }
  }

  render() {
    const { _onItemAdd, _onItemRemove, _onNewKeyword, _onNewPerson } = this
    let {
      name,
      resourceType,
      values,
      multiple,
      extensible,
      allowedTypes,
      searchParams,
      autocompleteConfig,
      withRoles,
      metaKey,
      autoCompleteSuggestionRenderer
    } = this.props
    values = f.compact(this.state.values || values)
    const { selectedRole, roles } = this.state

    // NOTE: this is only supposed to be used client side,
    // but we need to wait until AutoComplete is loaded
    if (!AutoComplete) {
      return null
    }

    return (
      <div className="form-item">
        <div className="multi-select">
          <ul className="multi-select-holder">
            {!withRoles &&
              f.map(values, (item, i) => {
                const remover = f.curry(_onItemRemove)(i)
                const style = item.isNew ? { fontStyle: 'italic' } : {}
                return (
                  <li
                    className="multi-select-tag"
                    style={style}
                    key={
                      item.uuid ||
                      (typeof item.getId === 'function' ? item.getId() : undefined) ||
                      JSON.stringify(item)
                    }>
                    {decorateResource(item)}
                    <a className="multi-select-tag-remove" onClick={remover}>
                      <i className="icon-close" />
                    </a>
                  </li>
                )
              })}
            {(() => {
              if (multiple || f.isEmpty(values)) {
                // allow adding *new* keywords:
                let addNewValue
                if (extensible && resourceType === 'Keywords') {
                  addNewValue = _onNewKeyword
                }

                return (
                  <div>
                    <li className="multi-select-input-holder mbs">
                      <AutoComplete
                        className="multi-select-input"
                        name={name}
                        resourceType={resourceType}
                        searchParams={searchParams}
                        onSelect={_onItemAdd}
                        config={autocompleteConfig}
                        existingValues={() =>
                          f.map(this.state.values, resourceType === 'People' ? 'uuid' : 'label')
                        }
                        valueGetter={resourceType === 'People' ? x => x.uuid : undefined}
                        onAddValue={addNewValue}
                        ref="ListAdder"
                        suggestionRenderer={autoCompleteSuggestionRenderer}
                      />
                      <a className="multi-select-input-toggle icon-arrow-down" />
                    </li>
                    {resourceType === 'People' ? (
                      <NewPersonWidget
                        id={`${f.snakeCase(name)}_new_person`}
                        allowedTypes={allowedTypes}
                        onAddValue={_onNewPerson}
                      />
                    ) : undefined}
                    {(() => {
                      if (withRoles && f.present(this.state.editedItem)) {
                        const { _onRoleSelect, _onNewRole } = this
                        return (
                          <div className="multi-select mts">
                            <label className="form-label pvs phn">
                              {f.present(this.state.editedRole)
                                ? t('meta_data_role_edit_heading')
                                : t('meta_data_role_add_heading')}
                              <strong> {decorateResource(this.state.editedItem, false)}</strong>
                            </label>
                            <div className="mbs" style={{ display: 'flex', gap: '1.5rem' }}>
                              <div style={{ flex: '40% 1 0' }} className="ptx ui-role-select mbs">
                                {selectedRole ? (
                                  <div
                                    style={{
                                      backgroundImage: 'linear-gradient(to top, #eeeeee, #f3f3f3)',
                                      border: '1px solid #eeeeee',
                                      borderRadius: '5px',
                                      padding: '0 5px'
                                    }}>
                                    {selectedRole.label}
                                  </div>
                                ) : undefined}
                                <div className="multi-select-input-holder mtn">
                                  <AutoComplete
                                    className="multi-select-input mbx"
                                    name="role_id"
                                    resourceType="Roles"
                                    searchParams={searchParams}
                                    onSelect={_onRoleSelect}
                                    config={{ minLength: 0, localData: roles }}
                                    onAddValue={metaKey.is_extensible ? _onNewRole : undefined}
                                    ref="roleSelect"
                                  />
                                  <a className="multi-select-input-toggle icon-arrow-down" />
                                </div>
                              </div>
                              <div style={{ flex: '60% 0 1' }}>
                                {metaKey.is_extensible
                                  ? t('meta_data_extensible_role_choose_label')
                                  : t('meta_data_role_choose_label')}
                              </div>
                            </div>
                            <div className="ui-form-group limited-width-s pan">
                              <button
                                className="add-person button"
                                onClick={this._onRoleSave}
                                ref="saveRoleButton">
                                {t('meta_data_input_person_save')}
                              </button>
                              <button
                                className="update-person button mls"
                                onClick={this._onRoleCancel}>
                                {t('meta_data_form_cancel')}
                              </button>
                            </div>
                          </div>
                        )
                      }
                    })()}
                    {withRoles ? (
                      <table className="block mts">
                        <tbody>
                          {values.map((item, i) => {
                            let role
                            return (
                              <tr key={i}>
                                <td className="pas">
                                  <strong className="mrs">{i + 1}.</strong>
                                  {decorateResource(item)}
                                  {(() => {
                                    if (f.present(item.role)) {
                                      ;({ role } = item)
                                      return (
                                        <span
                                          className="mbs"
                                          style={{ float: 'right' }}
                                          key={role.id}>
                                          <a
                                            href="#"
                                            onClick={e => this._onRoleEdit(role, i, e)}
                                            className="mls button small">
                                            {t('meta_data_role_edit_btn')}
                                          </a>
                                          <a
                                            href="#"
                                            onClick={e => this._onRoleRemove(i, e)}
                                            className="mlx button small">
                                            {t('meta_data_role_remove_btn')}
                                          </a>
                                        </span>
                                      )
                                    }
                                  })()}
                                </td>
                                <td style={{ width: '160px' }} className="pvs by-center">
                                  {f.present(item.role) ? (
                                    <a
                                      href="#"
                                      onClick={e => this._onRoleAdd(i, e)}
                                      className="button small">
                                      + {t('meta_data_role_add_another_btn')}
                                    </a>
                                  ) : undefined}
                                  {!f.present(item.role) ? (
                                    <a
                                      href="#"
                                      onClick={e => this._onRoleAdd(i, e)}
                                      className="button small">
                                      + {t('meta_data_role_add_btn')}
                                    </a>
                                  ) : undefined}
                                </td>
                                <td style={{ width: '32px' }} className="pvs by-center">
                                  {i < values.length - 1 && (
                                    <a
                                      className="button small"
                                      onClick={e => this._handleMoveDown(i, e)}>
                                      <span className="icon-arrow-down" />
                                    </a>
                                  )}
                                </td>
                                <td style={{ width: '32px' }} className="pvs by-center">
                                  {i > 0 && (
                                    <a
                                      className="button small"
                                      onClick={e => this._handleMoveUp(i, e)}>
                                      <span className="icon-arrow-up" />
                                    </a>
                                  )}
                                </td>
                                <td style={{ width: '30px' }} className="pas by-center">
                                  <a onClick={e => this._onItemRemove(i, e)}>
                                    <i className="icon-close" />
                                  </a>
                                </td>
                              </tr>
                            )
                          })}
                        </tbody>
                      </table>
                    ) : undefined}
                  </div>
                )
              }
            })()}
          </ul>
        </div>
        {f.map(f(values).presence() || [''], function (item) {
          // persisted resources have and only need a uuid (as string)
          const keyValuePairs = (() => {
            if (item.uuid && !f.has(item, 'role')) {
              return [[name, item.uuid]]

              // new resources are sent as on object (with all the attributes)
            } else if (item.type === 'Keyword') {
              return [[name + '[term]', item.term]]
            } else if (item.type === 'Person') {
              const newItem = item.isNew ? item : f.pick(item, ['uuid', 'role'])
              return f(newItem)
                .omit(['type', 'isNew'])
                .map(function (val, key) {
                  // pairs; build keys; clean & stringify values:
                  if (f.isArray(val)) {
                    val = val.map(v => v.id).join(',')
                  }
                  if (key === 'role' && !val.id && val.label) {
                    return [`${name}[${key}][term]`, val.label]
                  } else {
                    if (f.isPlainObject(val) && f.has(val, 'id')) {
                      val = val.id
                    }
                    if (f.present(val)) {
                      return [`${name}[${key}]`, val + '']
                    }
                  }
                })
                .compact()
                .value()

              // normal text fields are always just values:
            } else {
              return [[name, item.val]]
            }
          })()

          return [
            // protect hashes against form parsing bug:
            keyValuePairs.length > 1 ? (
              <input
                type="hidden"
                key="_hashmarker"
                name={`${name}[_hash]`}
                defaultValue="_start"
              />
            ) : undefined,
            f.map(keyValuePairs, function (item) {
              const [fieldName, value] = Array.from(item)
              return (
                <input
                  type="hidden"
                  key={value || `${name}_${fieldName}_empty`}
                  name={fieldName}
                  defaultValue={value}
                />
              )
            })
          ]
        })}
        {this.props.subForms}
      </div>
    )
  }
}

export default InputResources
