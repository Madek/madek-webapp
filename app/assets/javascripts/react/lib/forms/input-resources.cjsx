React = require('react')
f = require('../../../lib/fun.coffee')
InputFieldText = require('../forms/input-field-text.cjsx')
AutoComplete = 'div' # only required client-side, but falls back to div…

module.exports = React.createClass
  displayName: 'InputPeople'
  propTypes:
    name: React.PropTypes.string.isRequired
    resourceType: React.PropTypes.string.isRequired
    values: React.PropTypes.array.isRequired
    active: React.PropTypes.bool.isRequired
    multiple: React.PropTypes.bool.isRequired

  getInitialState: ()-> {active: false}

  componentDidMount: ({values} = @props)->
    AutoComplete = require('../autocomplete.cjsx')
    @setState # keep internal state of entered values
      values: values

  onItemAdd: (item)->
    unless f(@state.values).pluck('uuid').includes(item.uuid) # no duplicates!
      @setState(values: @state.values.concat(item), adding: true)
    # TODO: highlight the existing entry visually…

  onItemRemove: (item, _event)->
    @setState(values: f.reject(@state.values, item))

  componentDidUpdate: ()->
    if @state.adding
      @setState(adding: false)
      setTimeout(@refs.ListAdder.focus, 1)

  render: ({name, resourceType, values, active, multiple} = @props, state = @state)->
    {onItemAdd, onItemRemove} = @
    values = state.values or values

    <div className='form-item'>
      <div className='multi-select'>
        <ul className='multi-select-holder'>
          {values.map (item)->
            remover = f.curry(onItemRemove)(item)
            <li className='multi-select-tag' key={item.uuid}>
              {item.name}
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
                  ref='ListAdder'
                  onSelect={onItemAdd}/>
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
