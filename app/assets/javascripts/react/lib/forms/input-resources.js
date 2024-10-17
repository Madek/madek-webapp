const React = require('react')
const f = require('active-lodash')
const ui = require('../../lib/ui.coffee')
const t = ui.t
const decorateResource = require('../decorate-resource-names.coffee')
let AutoComplete = null // only required client-side!
const NewPersonWidget = require('./new-person-widget.cjsx')

module.exports = React.createClass({
  displayName: 'InputResources',
  propTypes: {
    name: React.PropTypes.string.isRequired,
    resourceType: React.PropTypes.string.isRequired,
    values: React.PropTypes.array.isRequired,
    multiple: React.PropTypes.bool.isRequired,
    extensible: React.PropTypes.bool, // only for Keywords
    allowedTypes: React.PropTypes.array, // only for People
    autocompleteConfig: React.PropTypes.shape({
      minLength: React.PropTypes.number
    })
  },

  getInitialState() {
    return {}
  },

  componentDidMount() {
    const { values, metaKey } = this.props
    AutoComplete = require('../autocomplete.js')
    this.setState({
      values: values, // keep internal state of entered values
      roles: metaKey && metaKey.roles ? [...metaKey.roles] : []
    })
  },

  /*
  NOTE: use a react legacy API to force updates to internal state when props changes.
  Using `componentWillReceiveProps` is *generally* not recommended, but in this case this is the most safe workaround for the current setup:
  This component is effectivly a fully constrolled, the internal state is only used for "derived state" and logic,
  which means its ok to do the "Anti-pattern: Erasing state when props change" here… 🤞
  TODO: try refactor away usage of state and only use props…
  */
  componentWillReceiveProps(nextProps) {
    if (this.props.values !== nextProps.values) {
      this.setState({ values: nextProps.values })
    }
  },

  _onItemAdd(item) {
    this._adding = true
    const is_duplicate = f.present(item.uuid)
      ? f(this.state.values)
          .map('uuid')
          .includes(item.uuid)
      : item.type === 'Keyword'
      ? f(this.state.values)
          .map('term')
          .includes(item.term)
      : item.type === 'Person'
      ? f.any(this.state.values, o => f.isEqual(o, item))
      : (() => {
          throw new Error('Unknown Resource type!')
        })()

    const newValues = this.state.values.concat(item)
    if (!is_duplicate) {
      this.setState({ values: newValues })
    }

    if (this.props.onChange) {
      this.props.onChange(newValues)
    }
  },

  _onRoleSave() {
    if (!f.present(this.state.selectedRole)) return

    const newValues = this.state.values.slice(0)
    const selectedRole = f.clone(this.state.selectedRole)

    if (this.state.addingRole === true) {
      if (f.has(this.state.editedItem, 'role') && !f.isEmpty(this.state.editedItem.role)) {
        const item = f.cloneDeep(this.state.editedItem)
        item.role = selectedRole
        newValues.push(item)
      } else {
        const itemIndex = this.state.editedItemIndex
        const item = f.cloneDeep(this.state.values[itemIndex])
        item.role = selectedRole
        newValues[itemIndex] = item
      }
    } else if (this.state.editedRole) {
      const itemIndex = this.state.editedRole.itemIndex
      const item = f.cloneDeep(this.state.values[itemIndex])
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
      this.props.onChange(newValues)
    }
  },

  _onNewKeyword(term) {
    this._onItemAdd({ type: 'Keyword', label: term, isNew: true, term: term })
  },

  _onNewPerson(obj) {
    this._onItemAdd(f.extend(obj, { type: 'Person', isNew: true }))
  },

  _onItemRemove(itemIndex, _event) {
    _event.stopPropagation()
    const newValues = this.state.values.slice(0)
    newValues.splice(itemIndex, 1)
    this.setState({ values: newValues })

    if (this.props.onChange) {
      this.props.onChange(newValues)
    }
  },

  _onRoleAdd(index, e) {
    e.preventDefault()

    const editedItem = this.state.values[index]
    this.setState({ editedItem: editedItem, editedItemIndex: index, addingRole: true })

    const refs = this.refs
    setTimeout(() => refs.roleSelect.focus(), 100)
  },

  _onRoleEdit(role, itemIndex, e) {
    e.preventDefault()

    this.setState({
      editedItem: this.state.values[itemIndex],
      editedRole: { id: role.id, itemIndex: itemIndex },
      selectedRole: role
    })

    const refs = this.refs
    setTimeout(() => refs.roleSelect.focus(), 100)
  },

  _onRoleSelect(role) {
    this.setState({ selectedRole: role })
    this.refs.saveRoleButton.focus()
  },

  _onNewRole(label) {
    const { roles } = this.state
    // assign existing if one by the same name already exists
    const r = f.find(roles, x => x.label === label)
    if (r) {
      this.setState({ selectedRole: r })
    } else {
      const newRole = { id: undefined, uuid: undefined, label: label, type: 'Role' }
      this.setState({ selectedRole: newRole, roles: [newRole, ...roles] })
    }
    this.refs.saveRoleButton.focus()
  },

  _onRoleRemove(itemIndex, e) {
    e.preventDefault()

    const newValues = this.state.values.slice(0)
    delete newValues[itemIndex].role
    this.setState({ values: newValues })

    if (this.props.onChange) {
      this.props.onChange(newValues)
    }
  },

  _onRoleCancel() {
    this.setState({
      editedRole: null,
      editedItemIndex: null,
      editedItem: null,
      selectedRole: null
    })
  },

  _handleMoveUp(itemIndex, e) {
    e.preventDefault()

    if (this.state.values[itemIndex - 1]) {
      const editedItem = this.state.values[itemIndex]
      const newValues = this.state.values.slice(0)
      newValues[itemIndex - 1] = f.cloneDeep(editedItem)
      newValues[itemIndex] = f.cloneDeep(this.state.values[itemIndex - 1])
      this.setState({ values: newValues })

      if (this.props.onChange) {
        this.props.onChange(newValues)
      }
    }
  },

  _handleMoveDown(itemIndex, e) {
    e.preventDefault()

    if (this.state.values[itemIndex + 1]) {
      const editedItem = this.state.values[itemIndex]
      const newValues = this.state.values.slice(0)
      newValues[itemIndex + 1] = f.cloneDeep(editedItem)
      newValues[itemIndex] = f.cloneDeep(this.state.values[itemIndex + 1])
      this.setState({ values: newValues })

      if (this.props.onChange) {
        this.props.onChange(newValues)
      }
    }
  },

  componentDidUpdate() {
    if (this._adding) {
      this._adding = false
      if (this.refs.ListAdder) {
        setTimeout(this.refs.ListAdder.focus, 1) // show the adder again
      }
    }
  },

  render() {
    const { _onItemAdd, _onItemRemove, _onNewKeyword, _onNewPerson } = this
    const {
      name,
      resourceType,
      values,
      multiple,
      extensible,
      allowedTypes,
      searchParams,
      autocompleteConfig,
      withRoles,
      metaKey
    } = this.props
    const currentValues = f.compact(this.state.values || values)
    const { selectedRole, roles } = this.state

    // NOTE: this is only supposed to be used client side,
    // but we need to wait until AutoComplete is loaded
    if (!AutoComplete) return null

    return (
      <div className="form-item">
        <div className="multi-select">
          <ul className="multi-select-holder">
            {!withRoles &&
              f.map(currentValues, (item, i) => {
                const remover = f.curry(_onItemRemove)(i)
                const style = item.isNew ? { fontStyle: 'italic' } : {}
                return (
                  <li
                    className="multi-select-tag"
                    style={style}
                    key={item.uuid || (item.getId && item.getId()) || JSON.stringify(item)}>
                    {decorateResource(item)}
                    <a className="multi-select-tag-remove" onClick={remover}>
                      <i className="icon-close" />
                    </a>
                  </li>
                )
              })}

            {/* add a value: */}
            {(multiple || f.isEmpty(currentValues)) && (
              <div>
                <li className="multi-select-input-holder mbs">
                  <AutoComplete
                    className="multi-select-input"
                    name={name}
                    resourceType={resourceType}
                    searchParams={searchParams}
                    onSelect={_onItemAdd}
                    config={autocompleteConfig}
                    existingValues={() => f.map(this.state.values, 'label')}
                    onAddValue={
                      extensible && resourceType === 'Keywords' ? _onNewKeyword : undefined
                    }
                    ref="ListAdder"
                  />
                  <a className="multi-select-input-toggle icon-arrow-down" />
                </li>

                {/* add a *new* Person.Person or Person.PeopleGroup */}
                {resourceType === 'People' && (
                  <NewPersonWidget
                    id={`${f.snakeCase(name)}_new_person`}
                    allowedTypes={allowedTypes}
                    onAddValue={_onNewPerson}
                  />
                )}

                {withRoles && f.present(this.state.editedItem) && (
                  <div className="multi-select mts">
                    <label className="form-label pvs phn">
                      {f.present(this.state.editedRole)
                        ? t('meta_data_role_edit_heading')
                        : t('meta_data_role_add_heading')}
                      <strong> {decorateResource(this.state.editedItem, false)}</strong>
                    </label>
                    <div className="mbs" style={{ display: 'flex', gap: '1.5rem' }}>
                      <div style={{ flex: '40% 1 0' }} className="ptx ui-role-select mbs">
                        {/* role select */}
                        {selectedRole && (
                          <div
                            style={{
                              backgroundImage: 'linear-gradient(to top, #eeeeee, #f3f3f3)',
                              border: '1px solid #eeeeee',
                              borderRadius: '5px',
                              padding: '0 5px'
                            }}>
                            {selectedRole.label}
                          </div>
                        )}
                        <div className="multi-select-input-holder mtn">
                          <AutoComplete
                            className="multi-select-input mbx"
                            name="role_id"
                            resourceType="Roles"
                            searchParams={searchParams}
                            onSelect={this._onRoleSelect}
                            config={{ minLength: 0, localData: roles }}
                            onAddValue={metaKey.is_extensible ? this._onNewRole : undefined}
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
                      <button className="update-person button mls" onClick={this._onRoleCancel}>
                        {t('meta_data_form_cancel')}
                      </button>
                    </div>
                  </div>
                )}

                {withRoles && (
                  <table className="block mts">
                    <tbody>
                      {currentValues.map((item, i) => (
                        <tr key={i}>
                          <td className="pas">
                            <strong className="mrs">{i + 1}.</strong>
                            {decorateResource(item)}

                            {f.present(item.role) && (
                              <span className="mbs" style={{ float: 'right' }} key={item.role.id}>
                                <a
                                  href="#"
                                  onClick={e => this._onRoleEdit(item.role, i, e)}
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
                            )}
                          </td>
                          <td style={{ width: '160px' }} className="pvs by-center">
                            {f.present(item.role) ? (
                              <a
                                href="#"
                                onClick={e => this._onRoleAdd(i, e)}
                                className="button small">
                                + {t('meta_data_role_add_another_btn')}
                              </a>
                            ) : (
                              <a
                                href="#"
                                onClick={e => this._onRoleAdd(i, e)}
                                className="button small">
                                + {t('meta_data_role_add_btn')}
                              </a>
                            )}
                          </td>
                          <td style={{ width: '32px' }} className="pvs by-center">
                            {i < currentValues.length - 1 && (
                              <a className="button small" onClick={e => this._handleMoveDown(i, e)}>
                                <span className="icon-arrow-down"></span>
                              </a>
                            )}
                          </td>
                          <td style={{ width: '32px' }} className="pvs by-center">
                            {i > 0 && (
                              <a className="button small" onClick={e => this._handleMoveUp(i, e)}>
                                <span className="icon-arrow-up"></span>
                              </a>
                            )}
                          </td>
                          <td style={{ width: '30px' }} className="pas by-center">
                            <a onClick={e => this._onItemRemove(i, e)}>
                              <i className="icon-close" />
                            </a>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )}
              </div>
            )}
          </ul>
        </div>

        {/* For form submit/serialization: always render values as hidden inputs, */}
        {/* in case of no values add an empty one (to distinguish removed values). */}
        {f.map(f(currentValues).presence() || [''], item => {
          // persisted resources have and only need a uuid (as string)
          const keyValuePairs =
            item.uuid && !f.has(item, 'role')
              ? [[name, item.uuid]]
              : item.type === 'Keyword'
              ? [[name + '[term]', item.term]]
              : item.type === 'Person'
              ? f(f(item.isNew ? item : f.pick(item, ['uuid', 'role'])).omit(['type', 'isNew']))
                  .map((val, key) => {
                    val = f.isArray(val) ? val.map(v => v.id).join(',') : val
                    return key === 'role' && !val.id && val.label
                      ? [`${name}[${key}][term]`, val.label]
                      : f.present(val)
                      ? [`${name}[${key}]`, val + '']
                      : null
                  })
                  .compact()
                  .value()
              : [[name, item.val]]

          return [
            // protect hashes against form parsing bug:
            keyValuePairs.length > 1 && (
              <input
                type="hidden"
                key="_hashmarker"
                name={`${name}[_hash]`}
                defaultValue={'_start'}
              />
            ),
            f.map(keyValuePairs, ([fieldName, value]) => (
              <input
                type="hidden"
                key={value || `${name}_${fieldName}_empty`}
                name={fieldName}
                defaultValue={value}
              />
            ))
          ]
        })}
        {this.props.subForms}
      </div>
    )
  }
})
