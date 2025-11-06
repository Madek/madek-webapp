import React from 'react'
import PropTypes from 'prop-types'
import Text from '../lib/forms/input-text-async.jsx'
import InputTextDate from '../lib/forms/InputTextDate.jsx'
import InputKeywords from '../lib/forms/input-keywords.jsx'
import InputPeople from '../lib/forms/input-people.jsx'
import InputJsonText from '../lib/forms/InputJsonText.jsx'
import InputMediaEntry from '../lib/forms/InputMediaEntry.jsx'

const InputMetaDatum = ({ id, name, model, metaKey, onChange, subForms, contextKey }) => {
  const resourceType = metaKey.value_type.split('::').pop()
  const multiple = (() => {
    switch (resourceType) {
      case 'Text':
      case 'TextDate':
      case 'JSON':
      case 'MediaEntry':
        return false
      case 'Keywords':
        return model.multiple
      default:
        return true
    }
  })()

  const values = model.values.map(value => value)

  if (resourceType === 'Text') {
    return (
      <Text metaKey={metaKey} name={name} values={values} onChange={onChange} subForms={subForms} />
    )
  } else if (resourceType === 'TextDate') {
    return (
      <InputTextDate onChange={onChange} id={id} name={name} values={values} subForms={subForms} />
    )
  } else if (resourceType === 'JSON') {
    return (
      <InputJsonText
        metaKey={metaKey}
        id={id}
        name={name}
        values={values}
        onChange={onChange}
        subForms={subForms}
      />
    )
  } else if (resourceType === 'People') {
    return (
      <InputPeople
        metaKey={metaKey}
        onChange={onChange}
        name={name}
        multiple={multiple}
        values={values}
        subForms={subForms}
        withRoles={metaKey.with_roles}
      />
    )
  } else if (resourceType === 'Keywords') {
    return (
      <InputKeywords
        meta_key={metaKey}
        keywords={metaKey.keywords}
        show_checkboxes={metaKey.show_checkboxes}
        onChange={onChange}
        id={id}
        name={name}
        multiple={multiple}
        values={values}
        metaKey={metaKey}
        contextKey={contextKey}
        subForms={subForms}
      />
    )
  } else if (resourceType === 'MediaEntry') {
    return (
      <InputMediaEntry
        meta_key={metaKey}
        onChange={onChange}
        id={id}
        name={name}
        values={values}
        subForms={subForms}
      />
    )
  } else {
    console.error('Unknown MetaDatum type!', resourceType)
    return null
  }
}

InputMetaDatum.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired
}

export default InputMetaDatum
module.exports = InputMetaDatum
