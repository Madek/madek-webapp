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
    console.log('componentDidMount->roles', @props)
    AutoComplete = require('../autocomplete.cjsx')
    defaultRole = f.get(@props, 'metaKey.roles[0]')
    defaultRole = { id: defaultRole.uuid, term: defaultRole.name } if defaultRole
    console.log('defaultRole', defaultRole)
    # TODO: make selection a collection to keep track of persistent vs on the fly values
    @setState
      values: values # keep internal state of entered values
      role: defaultRole

  _onItemAdd: (item)->
    # console.log('_onItemAdd', item)
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

    if @state.addingRole is true
      if f.has(@state.editedItem, 'role') and not f.isEmpty(@state.editedItem.role)
        item = f.cloneDeep(@state.editedItem)
        item.role = f.clone(@state.selectedRole)
        newValues.push(item)
      else
        itemIndex = @state.editedItemIndex
        item = f.cloneDeep(@state.values[itemIndex])
        item.role = f.clone(@state.selectedRole)
        newValues[itemIndex] = item
    else if @state.editedRole
      itemIndex = @state.editedRole.itemIndex
      item = f.cloneDeep(@state.values[itemIndex])
      item.role = {id: @state.selectedRole.id, term: @state.selectedRole.term}
      newValues[itemIndex] = item

    @setState(
      values: newValues
      editedItem: null
      editedItemIndex: null
      addingRole: null
      editedRole: null
    )

  _onNewKeyword: (term)->
    @_onItemAdd({ type: 'Keyword', label: term, isNew: true, term: term })

  _onNewPerson: (obj)->
    @_onItemAdd(f.extend(obj, { type: 'Person', isNew: true }))

  _onItemRemove: (item, _event)->
    _event.stopPropagation()
    newValues = f.reject(@state.values, item)
    @setState(values: newValues)

    if @props.onChange
      @props.onChange(newValues)

  _onRoleAdd: (index, e) ->
    e.preventDefault()

    editedItem = @state.values[index]
    @setState(editedItem: editedItem, editedItemIndex: index, addingRole: true)

  _renderRoleSelect: (name, roles, _onRoleSelect = @_onRoleSelect, model = @state.editItem) ->
    <select
      name={name}
      onChange={_onRoleSelect}
      value={f.get(@state, 'selectedRole.id') || f.get(@state, 'editedRole.id')}>
      {roles.map (role) ->
        <option value={role.uuid} key={role.uuid}>
          {role.name}
        </option>
      }
    </select>

  _onRoleSelect: (e) ->
    roleId = e.target.value
    index = e.target.selectedIndex
    roleName = e.target[index].text

    @setState(selectedRole: { id: roleId, term: roleName })

  _onRoleEdit: (roleId, itemIndex, e) ->
    e.preventDefault()

    @setState(
      editedItem: @state.values[itemIndex]
      editedRole: { id: roleId, itemIndex: itemIndex }
    )

  _onRoleRemove: (itemIndex, e) ->
    e.preventDefault()

    newValues = @state.values.slice(0)
    delete newValues[itemIndex].role
    @setState(values: newValues)

  _onRoleCancel: () ->
    @setState(
      role: null
      editedRole: null
      editedItemIndex: null
      editedItem: null
    )

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
          {!withRoles and values.map (item) =>
            remover = f.curry(_onItemRemove)(item)
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
                  onAddValue={_onNewPerson}
                  roles={@props.metaKey.roles}/>}

              {if withRoles and f.present(@state.editedItem)
                <div className='multi-select mts'>
                  <label className="form-label pas">
                    {if f.present(@state.editedRole) then 'Edit the role of' else 'Add a role to'} 
                    <strong> {f.trim("#{@state.editedItem.first_name} #{@state.editedItem.last_name}")}</strong>
                  </label>
                  <hr/>
                  <div className='ui-form-group test'>
                    <label className='form-label mrs'>{"Choose the role"}</label>
                    {@_renderRoleSelect('role_id', @props.metaKey.roles)}
                  </div>
                  <div className='ui-form-group limited-width-s pan'>
                    <button className='add-person button' onClick={@_onRoleSave}>
                      {t('meta_data_input_person_save')}
                    </button>
                    <button className='update-person button mls' onClick={@_onRoleCancel}>
                      {'Cancel'}
                    </button>
                  </div>
                </div>
              }

              {if withRoles
                <table className='block multi-selectX mts'>
                  <tbody>
                  {values.map (item, i) =>
                    <tr key={i}>
                      <td className='pas'>
                        <strong className='mrs'>{item.position}.</strong>{decorateResource(item)}

                        {if f.present(item.role)
                          (role = item.role)
                          <span className="mbs" key={role.id}>
                            <a href="#" onClick={(e) => @_onRoleEdit(role.id, i, e)} className='mls button small'>Edit role</a>
                            <a href="#" onClick={(e) => @_onRoleRemove(i, e)} className='mlxs button small'>Remove role</a>
                          </span>
                        }
                      </td>
                      <td style={{width: '30px'}} className='pas by-center'>
                        {if f.present(item.role)
                          <a href="#" onClick={(e) => @_onRoleAdd(i, e)} className='button small mls'>+ Add another role</a>}
                        {unless f.present(item.role)
                          <a href="#" onClick={(e) => @_onRoleAdd(i, e)} className='button small mls'>+ Add a role</a>}
                      </td>
                      <td style={{width: '12px'}} className='pas by-center'>
                        {i < values.length - 1 and (
                          <a className='button small' onClick={(e) => console.log('move down')}>
                            <span className='icon-arrow-down'></span>
                          </a>)}
                      </td>
                      <td style={{width: '12px'}} className='pas by-center'>
                        {i > 0 and (
                          <a className='button small' onClick={(e) => console.log('move up')}>
                            <span className='icon-arrow-up'></span>
                          </a>)}
                      </td>
                      <td style={{width: '30px'}} className='pas by-center'>
                        <a onClick={(e) => @_onItemRemove(item, e)}>
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
          # console.log('***')
          # console.log('newItem', newItem)
          # console.log(f(item).omit(['type', 'isNew']).value())
          # console.log(f(item).omit(['type', 'isNew']).map((val, key) -> if f.present(val) then ["#{name}[#{key}]", (val + '')]).value())
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
