React = require('react')
f = require('active-lodash')
MadekPropTypes = require('./madek-prop-types.coffee')

InputsByType = require('./forms/inputs-by-type.cjsx')

module.exports = React.createClass
  displayName: 'InputMetaDatum'
  propTypes:
    name: React.PropTypes.string.isRequired
    get: MadekPropTypes.metaDatum.isRequired

  getInitialState: ()-> {isClient: false}
  componentDidMount: ({get} = @props)->
    @setState
      isClient: true # internal marker to check for client side
      values: get.values # keep track of entered values

  onChange: (values)->
    @setState(values: values)

  render: ({get, name} = @props, state = @state)->
    resourceType = f.last(get.type.split('::'))

    # TODO: really check check if multiple allowed!
    multiple = not (f.includes(['Text', 'TextDate'], resourceType))

    # NOTE: in isClient mode, we operate with the objects (`values`),
    # otherwise everything is just strings (`literal_values`)!
    values = state.values or get.literal_values

    # enhance input if we are on client and there is a component,
    # otherwise use static text input:
    InputForType = if (state.isClient and InputsByType[resourceType])
      InputsByType[resourceType]
    else
      InputsByType.Text

    <InputForType
      get={get}
      name={name}
      active={state.isClient}
      multiple={multiple}
      values={values}/>
