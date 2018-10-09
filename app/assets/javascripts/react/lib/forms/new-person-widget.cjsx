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
  _emptyPerson: ()-> { type: 'Person', subtype: PEOPLE_SUBTYPES[0]}

  getInitialState: ()-> {
    isOpen: false,
    newPerson: @_emptyPerson()
  }
  componentDidMount: ({values} = @props)->
    AutoComplete = require('../autocomplete.cjsx')

    @setState
      values: [] # keep internal state of entered values
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

  _inputField: (key)->
    <input type='text' className='block'
      name={key} value={@state.newPerson[key] || ''}
      onChange={f.curry(@_onUpdateField)(key)}/>

  _onSubmit: (event)->
    # NEVER trigger (parent form!) submit on button click
    event.preventDefault()
    @props.onAddValue(@state.newPerson)
    @setState(isOpen: false, newPerson: @_emptyPerson())

  _selectRole: (role) ->
    console.log('_selectRole')
    console.log(arguments)
    newValues = this.state.values.concat(role)
    this.setState(values: newValues)

  _onRoleSelect: (e) ->
    alert('selected role: ' + e.target.value)

  render: ({id, allowedTypes} = @props)->
    supportsAnyAllowedType = f.any(allowedTypes, (t) -> f.includes(SUPPORTED_PEOPLE_SUBTYPES, t))
    # if (!supportsAnyAllowedType) then return false
    values = @state.values || []
    roles = @props.roles || []
    # roles = []
    # console.log('roles', roles)
    allowedTypes = ['Person', 'Group']

    paneClass = 'ui-container pam bordered rounded-right rounded-bottom'
    <div onKeyPress={@_onKeyPress}>
      <a className='button small form-widget-toggle'
        onClick={@_toggleOpen}>
        <Icon i='privacy-private' mods='small'/>
        {# only show the text when widget is closed:}
        {' ' + t('meta_data_input_new_person_toggle') unless @state.isOpen}
      </a>
      {if @state.isOpen
        <Tab.Container id={id} className='form-widget'
          defaultActiveKey='Person' animation={false} onSelect={@_onTabChange}
          >
          <div>
            <Nav className='ui-tabs ui-container' >
              <NavItem eventKey='Person' className='ui-tabs-item mll pls'>
                Person
              </NavItem>
              <NavItem eventKey='PeopleGroup'  className='ui-tabs-item'>
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

                      <label className='form-label'>Role</label>
                      <select
                        onChange={@_onRoleSelect}
                        value='---'>
                        {roles.map (role) ->
                          <option value={role.uuid} key={role.uuid}>
                            {role.name}
                          </option>
                        }
                      </select>
                      <div>or</div>
                      <AutoComplete className='multi-select-input'
                        name='role'
                        resourceType='Roles'
                        onSelect={this._selectRole} />
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
    </div>
