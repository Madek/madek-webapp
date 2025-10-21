import React, { useState } from 'react'
import PropTypes from 'prop-types'
import InputFieldText from '../forms/input-field-text.jsx'

const InputTextAsync = ({ name, values: initialValues, metaKey, onChange, subForms }) => {
  const [values, setValues] = useState(initialValues)

  const handleChange = event => {
    const newValues = [event.target.value]
    setValues(newValues)

    if (onChange) {
      onChange(newValues)
    }
  }

  const value = values.length === 0 ? '' : values[0]

  return (
    <div className="form-item">
      <div className="form-item-values">
        <InputFieldText
          onChange={handleChange}
          name={name}
          value={value}
          key={metaKey.uuid}
          metaKey={metaKey}
        />
      </div>
      {subForms}
    </div>
  )
}

InputTextAsync.propTypes = {
  name: PropTypes.string.isRequired,
  values: PropTypes.array.isRequired
}

export default InputTextAsync
module.exports = InputTextAsync
