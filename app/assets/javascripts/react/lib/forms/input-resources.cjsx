React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t
decorateResource = require('../decorate-resource-names.coffee')
Tabs = require('react-bootstrap/lib/Tabs')
Tab = require('react-bootstrap/lib/Tab')
Nav = require('react-bootstrap/lib/Nav')
NavItem = require('react-bootstrap/lib/NavItem')
MadekPropTypes = require('../../lib/madek-prop-types.coffee')
{Icon, Tooltipped} = require('../../ui-components/index.coffee')
AutoComplete = null # only required client-side!
NewPersonWidget = require('./new-person-widget.cjsx')

module.exports = React.createClass
  displayName: 'InputResources'
  propTypes:
    name: React.PropTypes.string.isRequired
    resourceType: React.PropTypes.string.isRequired
    values: React.PropTypes.array.isRequired
    multiple: React.PropTypes.bool.isRequired
    extensible: React.PropTypes.bool # only for Keywords
    allowedTypes: React.PropTypes.array # only for People
    autocompleteConfig: React.PropTypes.shape
      minLength: React.PropTypes.number

  getInitialState: ()-> {}

  componentDidMount: ({values} = @props)->
    AutoComplete = require('../autocomplete.cjsx')
    # TODO: make selection a collection to keep track of persistent vs on the fly values
    @setState
      values: values # keep internal state of entered values
      selectedRole: @defaultRole()

  defaultRole: ->
    if firstRole = f.get(@props.metaKey, 'roles[0]')
      { id: firstRole.uuid, label: firstRole.name }

  _onItemAdd: (item)->
    @_adding = true
    # TODO: use collection…
    is_duplicate = if f.present(item.uuid)
      f(@state.values).map('uuid').includes(item.uuid)
    else \ # check for NEW values…
      if item.type == 'Keyword'
        f(@state.values).map('term').includes(item.term)
      else if item.type == 'Person'
        f.any(@state.values, (o)-> f.isEqual(o, item))
      else
        throw new Error("Unknown Resource type!")

    newValues = @state.values.concat(item)
    unless is_duplicate
      @setState(values: newValues)

    if @props.onChange
      @props.onChange(newValues)

  _onRoleSave: ->
    return unless f.present(@state.selectedRole)

    newValues = @state.values.slice(0)
    selectedRole = f.clone(@state.selectedRole)

    if @state.addingRole is true
      if f.has(@state.editedItem, 'role') and not f.isEmpty(@state.editedItem.role)
        item = f.cloneDeep(@state.editedItem)
        item.role = selectedRole
        newValues.push(item)
      else
        itemIndex = @state.editedItemIndex
        item = f.cloneDeep(@state.values[itemIndex])
        item.role = selectedRole
        newValues[itemIndex] = item
    else if @state.editedRole
      itemIndex = @state.editedRole.itemIndex
      item = f.cloneDeep(@state.values[itemIndex])
      item.role = selectedRole
      newValues[itemIndex] = item

    @setState(
      values: newValues
      editedItem: null
      editedItemIndex: null
      addingRole: null
      editedRole: null
      selectedRole: @defaultRole()
    )

  _onNewKeyword: (term)->
    @_onItemAdd({ type: 'Keyword', label: term, isNew: true, term: term })

  _onNewPerson: (obj)->
    @_onItemAdd(f.extend(obj, { type: 'Person', isNew: true }))

  _onItemRemove: (itemIndex, _event)->
    _event.stopPropagation()
    newValues = @state.values.slice(0)
    newValues.splice(itemIndex, 1)
    @setState(values: newValues)

    if @props.onChange
      @props.onChange(newValues)

  _onRoleAdd: (index, e) ->
    e.preventDefault()

    editedItem = @state.values[index]
    @setState(editedItem: editedItem, editedItemIndex: index, addingRole: true)

  _renderRoleSelect: ->
    selectedRoleId = f.get(@state, 'selectedRole.id')

    <select
      name='role_id'
      onChange={@_onRoleSelect}
      value={selectedRoleId}>
      {@props.metaKey.roles.map (role) ->
        <option value={role.uuid} key={role.uuid}>
          {role.name}
        </option>
      }
    </select>

  _onRoleSelect: (e) ->
    roleId = e.target.value
    role = f.find(@props.metaKey.roles, (r) -> r.id is roleId)

    @setState(selectedRole: role)

  _onRoleEdit: (roleId, itemIndex, e) ->
    e.preventDefault()
    role = f.find(@props.metaKey.roles, (r) -> r.id is roleId)

    @setState(
      editedItem: @state.values[itemIndex]
      editedRole: { id: roleId, itemIndex: itemIndex }
      selectedRole: role
    )

  _onRoleRemove: (itemIndex, e) ->
    e.preventDefault()

    newValues = @state.values.slice(0)
    delete newValues[itemIndex].role
    @setState(values: newValues)

  _onRoleCancel: () ->
    @setState(
      editedRole: null
      editedItemIndex: null
      editedItem: null
      selectedRole: @defaultRole()
    )

  _handleMoveUp: (itemIndex, e) ->
    e.preventDefault()

    if previousItem = @state.values[itemIndex - 1]
      editedItem = @state.values[itemIndex]
      newValues = @state.values.slice(0)
      newValues[itemIndex - 1] = f.cloneDeep(editedItem)
      newValues[itemIndex] = f.cloneDeep(previousItem)
      @setState(values: newValues)

  _handleMoveDown: (itemIndex, e) ->
    e.preventDefault()

    if nextItem = @state.values[itemIndex + 1]
      editedItem = @state.values[itemIndex]
      newValues = @state.values.slice(0)
      newValues[itemIndex + 1] = f.cloneDeep(editedItem)
      newValues[itemIndex] = f.cloneDeep(nextItem)
      @setState(values: newValues)

  componentDidUpdate: ()->
    if @_adding
      @_adding = false
      setTimeout(@refs.ListAdder.focus, 1) # show the adder again

  render: ()->
    {_onItemAdd, _onItemRemove, _onNewKeyword, _onNewPerson} = @
    { name, resourceType, values, multiple, extensible, allowedTypes
      searchParams, autocompleteConfig, withRoles } = @props
    state = @state
    values = state.values or values

    # NOTE: this is only supposed to be used client side,
    # but we need to wait until AutoComplete is loaded
    return null unless AutoComplete

    <div className='form-item'>
      <div className='multi-select'>
        <ul className='multi-select-holder'>
          {!withRoles and values.map (item, i) =>
            remover = f.curry(_onItemRemove)(i)
            style = if item.isNew then {fontStyle: 'italic'} else {}
            <li className='multi-select-tag' style={style} key={item.uuid or item.getId?() or JSON.stringify(item)}>
              {decorateResource(item)}
              <a className='multi-select-tag-remove' onClick={remover}>
                <i className='icon-close'/>
              </a>
            </li>
          }

          {# add a value: }
          {if multiple or f.empty(values)

            # allow adding *new* keywords:
            if extensible and (resourceType is 'Keywords')
              addNewValue = _onNewKeyword

            <div>
              <li className='multi-select-input-holder mbs'>
                <AutoComplete className='multi-select-input'
                  name={name}
                  resourceType={resourceType}
                  searchParams={searchParams}
                  onSelect={_onItemAdd}
                  config={autocompleteConfig}
                  existingValues={() => f.map(@state.values, 'label')}
                  onAddValue={addNewValue}
                  ref='ListAdder'/>
                <a className='multi-select-input-toggle icon-arrow-down'/>
              </li>

              {# add a *new* Person.Person or Person.PeopleGroup}
              {if resourceType is 'People'
                <NewPersonWidget id={"#{f.snakeCase(name)}_new_person"}
                  allowedTypes={allowedTypes}
                  onAddValue={_onNewPerson}/>}

              {if withRoles and f.present(@state.editedItem)
                <div className='multi-select mts'>
                  <label className="form-label pas">
                    {if f.present(@state.editedRole) then t('meta_data_role_edit_heading') else t('meta_data_role_add_heading')} 
                    <strong> {decorateResource(@state.editedItem, false)}</strong>
                  </label>
                  <hr/>
                  <div className='ui-form-group'>
                    <label className='form-label mrs'>{t('meta_data_role_choose_label')}</label>
                    {@_renderRoleSelect()}
                  </div>
                  <div className='ui-form-group limited-width-s pan'>
                    <button className='add-person button' onClick={@_onRoleSave}>
                      {t('meta_data_input_person_save')}
                    </button>
                    <button className='update-person button mls' onClick={@_onRoleCancel}>
                      {t('meta_data_form_cancel')}
                    </button>
                  </div>
                </div>
              }

              {if withRoles
                <table className='block mts'>
                  <tbody>
                  {values.map (item, i) =>
                    <tr key={i}>
                      <td className='pas'>
                        <strong className='mrs'>{i+1}.</strong>{decorateResource(item)}

                        {if f.present(item.role)
                          (role = item.role)
                          <span className="mbs" style={{float: 'right'}} key={role.id}>
                            <a href="#" onClick={(e) => @_onRoleEdit(role.id, i, e)} className='mls button small'>{t('meta_data_role_edit_btn')}</a>
                            <a href="#" onClick={(e) => @_onRoleRemove(i, e)} className='mlx button small'>{t('meta_data_role_remove_btn')}</a>
                          </span>
                        }
                      </td>
                      <td style={{width: '160px'}} className='pvs by-center'>
                        {if f.present(item.role)
                          <a href="#" onClick={(e) => @_onRoleAdd(i, e)} className='button small'>+ {t('meta_data_role_add_another_btn')}</a>}
                        {unless f.present(item.role)
                          <a href="#" onClick={(e) => @_onRoleAdd(i, e)} className='button small'>+ {t('meta_data_role_add_btn')}</a>}
                      </td>
                      <td style={{width: '32px'}} className='pvs by-center'>
                        {i < values.length - 1 and (
                          <a className='button small' onClick={(e) => @_handleMoveDown(i, e)}>
                            <span className='icon-arrow-down'></span>
                          </a>)}
                      </td>
                      <td style={{width: '32px'}} className='pvs by-center'>
                        {i > 0 and (
                          <a className='button small' onClick={(e) => @_handleMoveUp(i, e)}>
                            <span className='icon-arrow-up'></span>
                          </a>)}
                      </td>
                      <td style={{width: '30px'}} className='pas by-center'>
                        <a onClick={(e) => @_onItemRemove(i, e)}>
                          <i className='icon-close'/>
                        </a>
                      </td>
                    </tr>
                  }
                  </tbody>
                </table>
              }

            </div>
          }
        </ul>
      </div>

      {# For form submit/serialization: always render values as hidden inputs, }
      {# in case of no values add an empty one (to distinguish removed values). }
      {f.map (f(values).presence() or ['']), (item)->
        # persisted resources have and only need a uuid (as string)
        keyValuePairs = if item.uuid and not f.has(item, 'role')
          [[name, item.uuid]]

        # new resources are sent as on object (with all the attributes)
        else if item.type is 'Keyword'
          [[name + '[term]', item.term]]
        else if item.type is 'Person'
          newItem = if item.isNew
            item
          else
            f.pick(item, ['uuid', 'role'])
          f(newItem).omit(['type', 'isNew'])
            .map((val, key)-> # pairs; build keys; clean & stringify values:
              val = val.map((v) => v.id).join(',') if f.isArray(val)
              val = val.id if f.isPlainObject(val) and f.has(val, 'id')
              if f.present(val) then ["#{name}[#{key}]", (val + '')])
            .compact().value()

        # normal text fields are always just values:
        else
          [[name, item.val]]

        [ # protect hashes against form parsing bug:
          if keyValuePairs.length > 1
            <input type='hidden' key='_hashmarker'
              name={"#{name}[_hash]"} defaultValue={'_start'} />
          ,
          f.map keyValuePairs, (item)->
            [fieldName, value] = item
            <input type='hidden' key={value || "#{name}_#{fieldName}_empty"}
              name={fieldName} defaultValue={value} />]
      }
      {@props.subForms}
    </div>
