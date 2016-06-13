React = require('react')
f = require('active-lodash')
InputFieldText = require('../forms/input-field-text.cjsx')

module.exports = React.createClass
  displayName: 'InputTextAsync'
  propTypes:
    name: React.PropTypes.string.isRequired
    values: React.PropTypes.array.isRequired
    active: React.PropTypes.bool.isRequired
    multiple: React.PropTypes.bool.isRequired


  getInitialState: () -> {
    values: []
  }

  componentWillMount: () ->
    @_ensureValues(@props.values)

  _ensureValues: (values) ->
    values = f.map values, (value) ->
      value
    if f.last(values) != ''
      if @props.multiple or f.isEmpty(values)
        values.push('')
    @setState({values: values})

  _onChange: (n, event) ->
    @state.values[n] = event.target.value
    @_ensureValues(@state.values)

    if @props.onChange
      @props.onChange(@state.values)

  render: ({get, name, values, active, multiple} = @props) ->

    onChange = if @props.onChange then @_onChange else null

    <div className='form-item'>
      <div className='form-item-values'>
        {
          @state.values.map (textValue, n) =>
            lc = if onChange then onChange.bind(@, n) else null
            <InputFieldText onChange={lc} name={name} value={textValue} key={get.meta_key_id + '_' + n}/>
        }
      </div>

    </div>
