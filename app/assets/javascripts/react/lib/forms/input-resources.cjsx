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
    autocompleteConfig: React.PropTypes.shape
      minLength: React.PropTypes.number

  getInitialState: ()-> {isClient: false}

  componentDidMount: ({values} = @props)->
    AutoComplete = require('../autocomplete.cjsx')
    @setState
      isClient: true
      values: values # keep internal state of entered values

  onItemAdd: (item)->
    @setState(adding: true)
    unless f(@state.values).map('uuid').includes(item.uuid) # no duplicates!
      @setState(values: @state.values.concat(item))
    # TODO: highlight the existing entry visually…

  onItemRemove: (item, _event)->
    @setState(values: f.reject(@state.values, item))

  componentDidUpdate: ()->
    if @state.adding
      @setState(adding: false)
      setTimeout(@refs.ListAdder.focus, 1)

  render: ({name, resourceType, searchParams, values, multiple, autocompleteConfig} = @props, state = @state)->
    {onItemAdd, onItemRemove} = @
    values = state.values or values

    # NOTE: this is only supposed to be used client side,
    # but we need to wait until AutoComplete is loaded
    return null unless AutoComplete

    <div className='form-item'>
      <div className='multi-select'>
        <ul className='multi-select-holder'>
          {values.map (item)->
            remover = f.curry(onItemRemove)(item)
            <li className='multi-select-tag' key={item.uuid}>
              {decorateResource(item)}
              <a className='multi-select-tag-remove' onClick={remover}>
                <i className='icon-close'/>
              </a>
            </li>
          }

          {if multiple or f.empty(values) # add a value:
            <li className='multi-select-input-holder'>
                <AutoComplete className='multi-select-input'
                  name={name}
                  resourceType={resourceType}
                  searchParams={searchParams}
                  onSelect={onItemAdd}
                  config={autocompleteConfig}
                  ref='ListAdder'/>
              <a className='multi-select-input-toggle icon-arrow-down'/>
            </li>
          }
        </ul>
      </div>
      {# For form submit/serialization: always render values as hidden inputs, }
      {# in case of no values add an empty one. }
      {f.map (f(values).pluck('uuid').presence() or ['']), (val)->
        <InputFieldText type='hidden' name={name} value={val} key={val||'empty'}/>
      }
    </div>
