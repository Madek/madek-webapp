React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
Text = require('../lib/forms/input-text-async.cjsx')
InputResources = require('../lib/forms/input-resources.cjsx')
InputTextDate = require('../lib/forms/InputTextDate.js').default
InputKeywords = require('../lib/forms/input-keywords.cjsx')
InputPeople = require('../lib/forms/input-people.cjsx')

module.exports = React.createClass
  displayName: 'InputMetaDatum'
  propTypes:
    id: React.PropTypes.string.isRequired
    name: React.PropTypes.string.isRequired
    get: MadekPropTypes.metaDatum.isRequired

  _inputByTypeMap: {
    'Text': Text
    'TextDate': InputTextDate
    'People': InputPeople
    'Keywords': InputKeywords
    # DEPRECATE_LICENSES act like/copied from keywords
    'Licenses': InputKeywords
  }

  render: ({get, id, name} = @props, state = @state)->

    resourceType = f.last(get.type.split('::'))

    multiple = not (f.includes(['Text', 'TextDate'], resourceType))

    InputElement = @_inputByTypeMap[resourceType]

    values = f.map get.values, (value) ->
      value

    <InputElement
      onChange={@props.onChange}
      get={get}
      id={id}
      name={name}
      multiple={multiple}
      values={values}
      metaKey={@props.metaKey}
      contextKey={@props.contextKey}
      subForms={@props.subForms}/>
