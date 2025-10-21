import React from 'react'
import PropTypes from 'prop-types'
import { isEmpty } from '../../../lib/utils.js'
import InputFieldText from '../forms/input-field-text.jsx'

const InputText = ({ name, values, multiple, subForms }) => {
  const shouldAddValue = isEmpty(values) || multiple

  return (
    <div className="form-item">
      <div className="form-item-values">
        {values.map((textValue, n) => (
          <InputFieldText name={name} value={textValue} key={n} />
        ))}
      </div>
      {shouldAddValue ? (
        <div className="form-item-add">
          <InputFieldText name={name} />
        </div>
      ) : undefined}
      {subForms}
    </div>
  )
}

InputText.propTypes = {
  name: PropTypes.string.isRequired,
  values: PropTypes.array.isRequired,
  active: PropTypes.bool.isRequired,
  multiple: PropTypes.bool.isRequired
}

export default InputText
module.exports = InputText
