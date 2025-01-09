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

  render: ({metaKey, name, values} = @props) ->

    <div className='form-item'>
      <div className='form-item-values'>
        {
          if @state.values.length == 0
            value = ''
          else
            value = @state.values[0]
          <InputFieldText onChange={@_onChange} name={name} value={value} key={metaKey.uuid}
            metaKey={metaKey} />
        }
      </div>
      {@props.subForms}
    </div>
