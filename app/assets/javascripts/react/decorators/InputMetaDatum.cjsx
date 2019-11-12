React = require('react')
f = require('active-lodash')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
Text = require('../lib/forms/input-text-async.cjsx')
InputResources = require('../lib/forms/input-resources.cjsx')
InputTextDate = require('../lib/forms/InputTextDate.js').default
InputKeywords = require('../lib/forms/input-keywords.cjsx')
InputPeople = require('../lib/forms/input-people.cjsx')
InputJsonText = require('../lib/forms/InputJsonText.js').default

module.exports = React.createClass
  displayName: 'InputMetaDatum'
  propTypes:
    id: React.PropTypes.string.isRequired
    name: React.PropTypes.string.isRequired

  render: ({id, name, model} = @props)->

    resourceType = f.last(@props.metaKey.value_type.split('::'))
    multiple = not (f.includes(['Text', 'TextDate', 'JSON'], resourceType))

    values = f.map model.values, (value) ->
      value

    if resourceType == 'Text'
      <Text
        metaKey={@props.metaKey}
        name={name}
        values={values}
        onChange={@props.onChange}
        subForms={@props.subForms} />

    else if resourceType == 'TextDate'
      <InputTextDate
        onChange={@props.onChange}
        id={id}
        name={name}
        values={values}
        subForms={@props.subForms}/>

    else if resourceType == 'JSON'
      <InputJsonText
        metaKey={@props.metaKey}
        id={id}
        name={name}
        values={values}
        onChange={@props.onChange}
        subForms={@props.subForms} />

    else if f.includes(['People', 'Roles'], resourceType)

      <InputPeople
        metaKey={@props.metaKey}
        onChange={@props.onChange}
        name={name}
        multiple={multiple}
        values={values}
        subForms={@props.subForms}
        withRoles={f.present(@props.metaKey.roles)}/>

    else if resourceType == 'Keywords'

      <InputKeywords
        meta_key={@props.metaKey}
        keywords={@props.metaKey.keywords}
        show_checkboxes={@props.metaKey.show_checkboxes}
        onChange={@props.onChange}
        id={id}
        name={name}
        multiple={multiple}
        values={values}
        metaKey={@props.metaKey}
        contextKey={@props.contextKey}
        subForms={@props.subForms}/>

    else
      return null
