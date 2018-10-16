React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t
# decorateResource = require('../decorate-resource-names.coffee')
Tabs = require('react-bootstrap/lib/Tabs')
Tab = require('react-bootstrap/lib/Tab')
Nav = require('react-bootstrap/lib/Nav')
NavItem = require('react-bootstrap/lib/NavItem')
MadekPropTypes = require('../../lib/madek-prop-types.coffee')
{Icon, Tooltipped} = require('../../ui-components/index.coffee')
AutoComplete = null # only required client-side!




# NOTE: only used client-side!
# NOTE: "form-like" inside <form>, careful!
PEOPLE_SUBTYPES = MadekPropTypes.PEOPLE_SUBTYPES
SUPPORTED_PEOPLE_SUBTYPES = ['Person', 'PeopleGroup']



module.exports = React.createClass
  displayName: 'NewPersonWidget'

  propTypes:
    id: React.PropTypes.string.isRequired
    onAddValue: React.PropTypes.func.isRequired
    # allowedTypes: React.PropTypes.arrayOf(
    #   React.PropTypes.oneOf(PEOPLE_SUBTYPES).isRequired
    # ).isRequired

  # NOTE: no models needed here yet:
  _emptyPerson: ()-> { type: 'Person', subtype: PEOPLE_SUBTYPES[0], role_id: '', role_name: '' }

  getInitialState: ()-> 
    # console.log('NewPersonWidget.getInitialState()', @props)
    {
      isOpen: false,
      # isEdited: false,
      newPerson: @_emptyPerson(),
      # editedPerson: @_emptyPerson(),
      # role_id: '',
      roles: []
    }
  componentDidMount: ({values, editItem} = @props)->
    # console.log('NewPersonWidget.componentDidMount()')
    AutoComplete = require('../autocomplete.cjsx')

    @setState
      values: [] # keep internal state of entered values
      # isOpen: !f.isNull(editItem)
      # editedPerson: editItem
      # isEdited: f.present(editItem)
  _toggleOpen: ()-> @setState(isOpen: !@state.isOpen)
  _onKeyPress: (event)->
    # NEVER trigger (parent form!) submit on ENTER
    event.preventDefault() if event.key is 'Enter'
    # TODO: move to next input field?

  _onTabChange: (eventKey)->
    @setState({ newPerson: { subtype: eventKey } })

  _onUpdateField: (key, event)->
    @setState(
      newPerson: f.extend(@state.newPerson, f.set({}, key, event.target.value)))
    # console.log('state after update', @state)
    # console.log(event.target)

  _inputField: (key)->
    # console.log('_inputField', arguments)
    # value = if f.present(existingPerson)
      # console.log('state', @state)
      # @state.editedPerson[key]
      # @props.editItem[key]
      # existingPerson[key]
    # else
      # @state.newPerson[key] || ''

    # console.log('value', value)
    
    <input type='text' className='block'
      name={key} value={@state.newPerson[key] || ''}
      onChange={f.curry(@_onUpdateField)(key)}/>

  # _roleSelect: (name, roles) ->
  #   <select
  #     name={name}
  #     onChange={@_onRoleSelect}
  #     value={@state[name]}>
  #     {roles.map (role) ->
  #       <option value={role.uuid} key={role.uuid}>
  #         {role.name}
  #       </option>
  #     }
  #   </select>

  _onSubmit: (event)->
    # NEVER trigger (parent form!) submit on button click
    event.preventDefault()
    @props.onAddValue(@state.newPerson)

    @setState(isOpen: false, newPerson: @_emptyPerson())

  _selectRole: (role) -> # autocomplete
    # console.log('_selectRole')
    # console.log(arguments)
    newValues = this.state.values.concat(role)
    this.setState(values: newValues)

  _onRoleSelect: (e) ->
    # console.log('NewPersonWidget->_onRoleSelect()')
    # console.log('[event object]', e.target)
    key = e.target.getAttribute('name')
    # console.log('key', key)
    # console.log('value', e.target.value)
    # @_onUpdateField(key, e)
    index = e.target.selectedIndex
    roleName =
      target:
        value: e.target[index].text
    # @_onUpdateField('role_name', roleName)
    # @setState({role_id: e.target.value})

    _newPerson = Object.assign({}, @state.newPerson)
    _newPerson.role_id = e.target.value
    _newPerson.role_name = e.target[index].text

    @setState(newPerson: _newPerson)

  render: ({id, allowedTypes, _roleSelect, isEditing} = @props)->
    # console.log('NewPersonWidget.render()', @props)
    supportsAnyAllowedType = f.any(allowedTypes, (t) -> f.includes(SUPPORTED_PEOPLE_SUBTYPES, t))
    # if (!supportsAnyAllowedType) then return false
    values = @state.values || []
    roles = @props.roles || []
    # roles = []
    # console.log('roles', roles)
    # allowedTypes = ['Person', 'Group']
    withRoles = f.present(@props.roles)
    # @setState(editedPerson: editItem)
    # editItem = false #@props.editItem
    # console.log('editItem:', editItem)
    # console.log('newPersonWidget->withRoles', withRoles)

    paneClass = 'ui-container pam bordered rounded-right rounded-bottom'
    toggleButtonTranslationKey = if withRoles
      'meta_data_input_new_person_toggle_only'
    else
      'meta_data_input_new_person_toggle'
    <div onKeyPress={@_onKeyPress}>
      <a className='button small form-widget-toggle'
        onClick={@_toggleOpen}>
        <Icon i='privacy-private' mods='small'/>
        {# only show the text when widget is closed:}
        {' ' + t(toggleButtonTranslationKey) unless @state.isOpen}
      </a>
      {if @state.isOpen && !withRoles
        <Tab.Container id={id} className='form-widget'
          defaultActiveKey='Person' onSelect={@_onTabChange}
          >
          <div>
            <Nav className='ui-tabs ui-container' >
              <NavItem eventKey='Person' className='ui-tabs-item mll pls'>
                Person
              </NavItem>
              <NavItem eventKey='PeopleGroup' className='ui-tabs-item'>
                Group
              </NavItem>
            </Nav>

            <Tab.Content animation={false} className='ui-tab-content mbs'>

              {allowedTypes.map((type) => (
                if (type == 'Person') then return (
                  <Tab.Pane eventKey={type} className={paneClass} key={type}>
                    <div className='ui-form-group rowed pbx ptx'>
                      <label className='form-label'>Vorname</label>
                      <div className='form-item'>
                        {@_inputField('first_name')}
                      </div>
                    </div>

                    <div className='ui-form-group rowed pbx ptx'>
                      <label className='form-label'>Nachname</label>
                      <div className='form-item'>
                        {@_inputField('last_name')}
                      </div>
                    </div>

                    <div className='ui-form-group rowed pbx ptx'>
                      <label className='form-label'>Pseudonym</label>
                      <div className='form-item'>
                        {@_inputField('pseudonym')}
                      </div>
                    </div>

                    <div className='ui-form-group rowed pbx ptx multi-select-input-holder mbs'>
                      <ul className='multi-select-holder'>
                        {values.map (item)->
                          remover = f.curry(_onItemRemove)(item)
                          style = if item.isNew then {fontStyle: 'italic'} else {}
                          <li className='multi-select-tag' style={style} key={item.uuid or item.getId?() or JSON.stringify(item)}>
                            {decorateResource(item)}
                            <a className='multi-select-tag-remove' onClick={remover}>
                              <i className='icon-close'/>
                            </a>
                          </li>
                        }
                      </ul>
                    </div>

                    <div className='ui-form-group rowed ptm limited-width-s'>
                      <button className='add-person button block' onClick={@_onSubmit}>
                        {t('meta_data_input_new_person_add')}
                      </button>
                    </div>
                  </Tab.Pane>)

                if type == 'PeopleGroup' then return (
                  <Tab.Pane eventKey={type} className={paneClass}>
                    <div className='ui-form-group rowed pbx ptx'>
                      <label className='form-label'>Name</label>
                      <div className='form-item'>
                        {@_inputField('first_name')}
                      </div>
                    </div>

                    <div className='ui-form-group rowed ptm limited-width-s'>
                      <button className='add-group button block' onClick={@_onSubmit}>
                        {t('meta_data_input_new_group_add')}
                      </button>
                    </div>
                  </Tab.Pane>)
              ))}

            </Tab.Content>

          </div>
        </Tab.Container>}

      {if @state.isOpen && withRoles && !isEditing
        {#<Tab.Pane eventKey='roles' className={paneClass + '_test'}>}
        <div className={paneClass + '_test'} style={{marginTop: '4px'}}>
          <div className='ui-form-group rowed pbx ptx'>
            <label className='form-label'>Vorname</label>
            <div className='form-item'>
              {@_inputField('first_name')}
            </div>
          </div>

          <div className='ui-form-group rowed pbx ptx'>
            <label className='form-label'>Nachname</label>
            <div className='form-item'>
              {@_inputField('last_name')}
            </div>
          </div>

          <div className='ui-form-group rowed pbx ptx'>
            <label className='form-label'>Pseudonym</label>
            <div className='form-item'>
              {@_inputField('pseudonym')}
            </div>
          </div>

          <div className='ui-form-group rowed pbx ptx multi-select-input-holder mbs'>
            <ul className='multi-select-holder'>
              {values.map (item)->
                remover = f.curry(_onItemRemove)(item)
                style = if item.isNew then {fontStyle: 'italic'} else {}
                <li className='multi-select-tag' style={style} key={item.uuid or item.getId?() or JSON.stringify(item)}>
                  {decorateResource(item)}
                  <a className='multi-select-tag-remove' onClick={remover}>
                    <i className='icon-close'/>
                  </a>
                </li>
              }
            </ul>

            <label className='form-label'>Role</label>
            {_roleSelect('role_id', roles, @_onRoleSelect, @state.newPerson)}
            {if false
              (
                <div>or</div>
                <AutoComplete className='multi-select-input'
                  name='role_id'
                  resourceType='Roles'
                  onSelect={@_selectRole} />
              )
            }
          </div>

          <div className='ui-form-group rowed ptm limited-width-s'>
            <button className='add-person button block' onClick={@_onSubmit}>
              {t('meta_data_input_new_person_add')}
            </button>
          </div>

          <div className='ui-form-group rowed pbx ptx'>
            <label className='form-label'>Notes (character etc.)</label>
            <div className='form-item'>
              {@_inputField('string')}
            </div>
          </div>
        </div>
        {#</Tab.Pane>}
      }
    </div>
