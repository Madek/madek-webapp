React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t('de')
decorateResource = require('../decorate-resource-names.coffee')
Tabs = require('react-bootstrap/lib/Tabs')
Tab = require('react-bootstrap/lib/Tab')
Nav = require('react-bootstrap/lib/Nav')
NavItem = require('react-bootstrap/lib/NavItem')
{Icon, Tooltipped} = require('../../ui-components/index.coffee')
InputFieldText = require('../forms/input-field-text.cjsx')
AutoComplete = null # only required client-side!

module.exports = React.createClass
  displayName: 'InputResources'
  propTypes:
    name: React.PropTypes.string.isRequired
    resourceType: React.PropTypes.string.isRequired
    values: React.PropTypes.array.isRequired
    active: React.PropTypes.bool.isRequired
    multiple: React.PropTypes.bool.isRequired
    extensible: React.PropTypes.bool # only for Keywords
    allowedTypes: React.PropTypes.array # only for People
    autocompleteConfig: React.PropTypes.shape
      minLength: React.PropTypes.number

  getInitialState: ()-> {isClient: false}

  componentDidMount: ({values} = @props)->
    AutoComplete = require('../autocomplete.cjsx')
    # TODO: make selection a collection to keep track of persistent vs on the fly values
    @setState
      isClient: true
      values: values # keep internal state of entered values

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
    # TODO: highlight the existing (in old value) and on the fly items visually…

    if @props.onChange
      @props.onChange(newValues)

  _onNewKeyword: (term)->
    @_onItemAdd({ type: 'Keyword', label: term, isNew: true, term: term })

  _onNewPerson: (obj)->
    @_onItemAdd(f.extend(obj, { type: 'Person', isNew: true }))

  _onItemRemove: (item, _event)->
    newValues = f.reject(@state.values, item)
    @setState(values: newValues)

    if @props.onChange
      @props.onChange(newValues)

  componentDidUpdate: ()->
    if @_adding
      @_adding = false
      setTimeout(@refs.ListAdder.focus, 1) # show the adder again

  render: ()->
    {_onItemAdd, _onItemRemove, _onNewKeyword, _onNewPerson} = @
    { name, resourceType, values, multiple, extensible, allowedTypes
      searchParams, autocompleteConfig } = @props
    state = @state
    values = state.values or values

    # NOTE: this is only supposed to be used client side,
    # but we need to wait until AutoComplete is loaded
    return null unless AutoComplete

    <div className='form-item'>
      <div className='multi-select'>
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
                  onAddValue={addNewValue}
                  ref='ListAdder'/>
                <a className='multi-select-input-toggle icon-arrow-down'/>
              </li>

              {# add a *new* Person.Person or Person.PeopleGroup}
              {if (resourceType is 'People')
                <NewPersonWidget id={"#{f.snakeCase(name)}_new_person"}
                  allowedTypes={allowedTypes}
                  onAddValue={_onNewPerson}/>}

            </div>
          }
        </ul>
      </div>

      {# For form submit/serialization: always render values as hidden inputs, }
      {# in case of no values add an empty one (to distinguish removed values). }
      {f.map (f(values).presence() or ['']), (item)->
        # persisted resources have and only need a uuid (as string)
        keyValuePairs = if item.uuid
          [[name, item.uuid]]

        # new resources are sent as on object (with all the attributes)
        else if item.type is 'Keyword'
          [[name + '[term]', item.term]]
        else if item.type is 'Person'
          f(item).omit(['type', 'isNew'])
            .map((val, key)-> # pairs; build keys; clean & stringify values:
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
    </div>


# NOTE: only used client-side!
# NOTE: "form-like" inside <form>, careful!
PEOPLE_SUBTYPES = ['Person', 'PeopleGroup', 'PeopleInstitutionalGroup']
SUPPORTED_PEOPLE_SUBTYPES = ['Person', 'PeopleGroup']
NewPersonWidget = React.createClass
  displayName: 'NewPersonWidget'
  propTypes:
    id: React.PropTypes.string.isRequired
    onAddValue: React.PropTypes.func.isRequired
    allowedTypes: React.PropTypes.arrayOf(
      React.PropTypes.oneOf(PEOPLE_SUBTYPES).isRequired
    ).isRequired

  # NOTE: no models needed here yet:
  _emptyPerson: ()-> { type: 'Person', subtype: PEOPLE_SUBTYPES[0]}

  getInitialState: ()-> {
    isOpen: false,
    newPerson: @_emptyPerson()
  }
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

  render: ({id, allowedTypes} = @props)->
    supportsAnyAllowedType = f.any(allowedTypes, (t) -> SUPPORTED_PEOPLE_SUBTYPES.includes(t))
    if (!supportsAnyAllowedType) then return false

    paneClass = 'ui-container pam bordered rounded-right rounded-bottom'
    <div onKeyPress={@_onKeyPress}>
      <Tooltipped text={t('meta_data_input_new_person_toggle')} id={"#{id}_new_person_toggle"}>
        <a title={t('meta_data_input_new_person_toggle')} className='button small form-widget-toggle'
          onClick={@_toggleOpen}>
          <Icon i='privacy-private' mods='small'/>
        </a>
      </Tooltipped>
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
                  <Tab.Pane eventKey={type} className={paneClass}>
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
    </div>
