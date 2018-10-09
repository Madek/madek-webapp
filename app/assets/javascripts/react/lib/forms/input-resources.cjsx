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

  getInitialState: ()-> { }

  componentDidMount: ({values, roles} = @props)->
    AutoComplete = require('../autocomplete.cjsx')
    # TODO: make selection a collection to keep track of persistent vs on the fly values
    @setState
      values: values # keep internal state of entered values
      roles: (roles || [])

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

    withRoles = @props.withRoles

    console.log('withRoles', withRoles)

    if withRoles is true
      console.log('input-resource @props', @props)

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
                  roles={@props.metaKey.roles}/>}

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
      {@props.subForms}
    </div>
