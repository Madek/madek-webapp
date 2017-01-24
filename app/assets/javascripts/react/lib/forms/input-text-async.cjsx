React = require('react')
f = require('active-lodash')
InputFieldText = require('../forms/input-field-text.cjsx')

module.exports = React.createClass
  displayName: 'InputTextAsync'
  propTypes:
    name: React.PropTypes.string.isRequired
    values: React.PropTypes.array.isRequired


  getInitialState: () -> {
    values: []
  }

  componentWillMount: () ->
    @setState({values: @props.values})

  _onChange: (event) ->
    newValues = [event.target.value]
    @setState({values: newValues})

    if @props.onChange
      @props.onChange(newValues)

  render: ({get, name, values} = @props) ->

    onChange = if @props.onChange then @_onChange else null

    <div className='form-item'>
      <div className='form-item-values'>
        {
          if @state.values.length == 0
            value = ''
          else
            value = @state.values[0]
          <InputFieldText onChange={@_onChange} name={name} value={value} key={get.meta_key_id}
            contextKey={@props.contextKey}/>
        }
      </div>
      {@props.subForms}
    </div>
