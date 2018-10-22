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

  getInitialState: ()-> {
    editItem: null
    role: null
  }

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
    # console.log('_onRoleSave()', arguments)

    return unless f.present(@state.role)

    # console.log('@state.editItem', @state.editItem)
    itemIndex = if @state.editedRole
      @state.editedRole.itemIndex
    else
      @state.editedItemIndex

    # itemIndex = @state.editedRole.itemIndex
    # console.log('itemIndex', itemIndex)
    newValues = @state.values.slice(0)
    # newValues[index] = @state.editItem
    editedItem = Object.assign({}, @state.values[itemIndex])

    # console.log('editedItem', editedItem)
    # return
    # newValues = [Object.assign({}, @state.editItem)]
    # editedItem.roles.push({id: @state.role.id, term: @state.role.term})
    newRoles = if f.isArray(editedItem.roles)
      editedItem.roles.slice(0)
    else
      []
    # newRoles = f.remove(editedItem.roles, (r) => r.id is not @state.role.id)
    # newRoles = newRoles.map (role) =>
    #   if role.id is @state.role.id
    # )

    if @state.editedRole
      roleIndex = newRoles.findIndex((nr) => nr.id is @state.editedRole.id)
      newRoles[roleIndex] = {id: @state.role.id, term: @state.role.term}
    else if not f.find(newRoles, {id: @state.role.id})
      newRoles.push({id: @state.role.id, term: @state.role.term})
    editedItem.roles = newRoles
    newValues[itemIndex] = editedItem

    @setState(
      editItem: null
      editedItemIndex: null
      editedRole: null
      values: newValues
      role: null
    )

  _onNewKeyword: (term)->
    @_onItemAdd({ type: 'Keyword', label: term, isNew: true, term: term })

  _onNewPerson: (obj)->
    # console.log('obj', obj)
    @_onItemAdd(f.extend(obj, { type: 'Person', isNew: true }))

  _onItemRemove: (item, _event)->
    _event.stopPropagation()
    newValues = f.reject(@state.values, item)
    @setState(values: newValues)

    if @props.onChange
      @props.onChange(newValues)

  _onItemEdit: (index, e) ->
    # console.log('_onItemEdit()', arguments)
    e.preventDefault()
    # @setState(editItem: Object.assign({}, item))
    editedItem = @state.values[index]
    @setState(editItem: editedItem, editedItemIndex: index)

  _renderRoleSelect: (name, roles, _onRoleSelect = @_onRoleSelect, model = @state.editItem) ->
    <select
      name={name}
      onChange={_onRoleSelect}
      value={f.get(@state, 'role.id') || f.get(@state, 'editedRole.id')}>
      {roles.map (role) ->
        <option value={role.uuid} key={role.uuid}>
          {role.name}
        </option>
      }
    </select>

  _onRoleSelect: (e) ->
    # console.log('_onRoleSelect', e)
    # console.log('state', @state)

    # newItem = Object.assign({}, @state.editItem)

    # key = e.target.getAttribute('name') # role_id
    roleId = e.target.value
    # newItem = f.set(@state.editItem, key, value)

    index = e.target.selectedIndex
    roleName = e.target[index].text
    # newItem = f.set(@state.editItem, 'role_name', roleName)
    # console.log('newItem', newItem)
    # newItem.roles.push({ role_id: roleId, role_name: roleName })
    @setState(role: { id: roleId, term: roleName })

  _onRoleEdit: (roleId, itemIndex, e) ->
    e.preventDefault()

    @setState(
      editItem: @state.values[itemIndex]
      editedRole: { id: roleId, itemIndex: itemIndex }
    )

  _onRoleRemove: (roleId, itemIndex, e) ->
    e.preventDefault()

    newValues = @state.values.slice(0)
    roleIndex = newValues[itemIndex].roles.findIndex((r) => r.id == roleId)
    newValues[itemIndex].roles.splice(roleIndex, 1)
    @setState(values: newValues)

  _onRoleCancel: () ->
    @setState(
      role: null
      editedRole: null
      editedItemIndex: null
      editItem: null
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
              {if (f.includes(['People', 'Roles'], resourceType))
                <NewPersonWidget id={"#{f.snakeCase(name)}_new_person"}
                  allowedTypes={allowedTypes}
                  onAddValue={_onNewPerson}
                  roles={@props.metaKey.roles}
                  _roleSelect={@_renderRoleSelect}
                  isEditing={f.present(@state.editItem)}/>}

              {if withRoles and f.present(@state.editItem)
                <div className='multi-select mts'>
                  <label className="form-label pas">
                    {if f.present(@state.editedRole) then 'Edit the role of' else 'Add a role to'} 
                    <strong> {f.trim("#{@state.editItem.first_name} #{@state.editItem.last_name}")}</strong>
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
                <table className='block multi-select mts'>
                  <thead>
                    <tr>
                      <th className='pas' style={{fontSize: '13px', backgroundColor: '#fafafa'}}><strong>Person / Group</strong></th>
                      <th className='pas' style={{fontSize: '13px', backgroundColor: '#fafafa'}}><strong>Roles</strong></th>
                      <th style={{background: '#fafafa', width: '30px'}}>&nbsp;</th>
                    </tr>
                  </thead>
                  <tbody>
                  {values.map (item, i) =>
                    <tr key={i}>
                      <td style={{width: '47%'}} className='pas'>
                        {decorateResource(item)}
                        <a href="#" onClick={(e) => @_onItemEdit(i, e)} className='mls'>+ Add a role</a>
                      </td>
                      <td className='pas'>
                        {f.isArray(item.roles) and item.roles.map (role) =>
                          <div className="mbs" key={role.id}>
                            - {role.term}
                            <a href="#" onClick={(e) => @_onRoleEdit(role.id, i, e)} className='mls'>Edit</a>,
                            <a href="#" onClick={(e) => @_onRoleRemove(role.id, i, e)} className='mls'>Remove</a>
                          </div>
                        }
                        {unless f.present(item.roles)
                          <em style={{fontStyle: 'italic', color: '#ccc'}}>No roles.</em>}
                      </td>
                      <td className='pas' style={{textAlign: 'center'}}>
                        <a onClick={(e) => @_onItemRemove(item, e)}>
                          <i className='icon-close'/>
                        </a>
                      </td>
                    </tr>
                  }
                  </tbody>
                </table>}

            </div>
          }
        </ul>
      </div>

      {# For form submit/serialization: always render values as hidden inputs, }
      {# in case of no values add an empty one (to distinguish removed values). }
      {f.map (f(values).presence() or ['']), (item)->
        # persisted resources have and only need a uuid (as string)
        keyValuePairs = if item.uuid and not f.has(item, 'roles')
          [[name, item.uuid]]

        # new resources are sent as on object (with all the attributes)
        else if item.type is 'Keyword'
          [[name + '[term]', item.term]]
        else if item.type is 'Person'
          newItem = if item.isNew
            item
          else
            f.pick(item, ['uuid', 'roles'])
          # console.log('***')
          # console.log('newItem', newItem)
          # console.log(f(item).omit(['type', 'isNew']).value())
          # console.log(f(item).omit(['type', 'isNew']).map((val, key) -> if f.present(val) then ["#{name}[#{key}]", (val + '')]).value())
          f(newItem).omit(['type', 'isNew'])
            .map((val, key)-> # pairs; build keys; clean & stringify values:
              val = val.map((v) => v.id).join(',') if f.isArray(val)
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
