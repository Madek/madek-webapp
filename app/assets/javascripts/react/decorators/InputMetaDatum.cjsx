React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../lib/madek-prop-types.coffee')

InputsByType = require('../lib/forms/inputs-by-type.cjsx')
InputText = require('../lib/forms/input-text.cjsx')

module.exports = React.createClass
  displayName: 'InputMetaDatum'
  propTypes:
    id: React.PropTypes.string.isRequired
    name: React.PropTypes.string.isRequired
    get: MadekPropTypes.metaDatum.isRequired

  render: ({get, id, name} = @props, state = @state)->

    resourceType = f.last(get.type.split('::'))

    multiple = not (f.includes(['Text', 'TextDate'], resourceType))

    InputForType = InputsByType[resourceType]
    values = f.map get.values, (value) ->
      value


    <InputForType
      onChange={@props.onChange}
      get={get}
      id={id}
      name={name}
      multiple={multiple}
      values={values}
      contextKey={@props.contextKey}
      subForms={@props.subForms}/>
