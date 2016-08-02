React = require('react')
f = require('active-lodash')
decorateResource = require('../decorate-resource-names.coffee')
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
    extensible: React.PropTypes.bool # only for keywords
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
    else
      f(@state.values).map('term').includes(item.term) # HACK!

    newValues = @state.values.concat(item)

    unless is_duplicate
      @setState(values: newValues)
    # TODO: highlight the existing (in old value) and on the fly items visually…

    if @props.onChange
      @props.onChange(newValues)

  _onNewItem: (value)->
    @_onItemAdd({ type: 'Keyword', label: value, isNew: true, term: value }) # HACK

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
    {_onItemAdd, _onItemRemove, _onNewItem} = @
    {name, resourceType, searchParams, values, multiple, extensible, autocompleteConfig} = @props
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

            # allow adding new keywords:
            if extensible and (resourceType is 'Keywords')
              addNewValue = _onNewItem

            <li className='multi-select-input-holder'>
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
          }
        </ul>
      </div>

      {# For form submit/serialization: always render values as hidden inputs, }
      {# in case of no values add an empty one. }
      {f.map (f(values).presence() or ['']), (item)->
        # persisted resources have and only need a uuid (as string)
        # new resources are sent as on object (with all the attributes)
        if item.uuid
          fieldName = name
          val = item.uuid
        else if item.type is 'Keyword' # HACK: only keywords…
          fieldName = name + '[term]'
          val = item.term
        else
          fieldName = name
          val = item.val

        <InputFieldText
          type='hidden' name={fieldName} value={val} key={val||'empty'}/>
      }
    </div>
