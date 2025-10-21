import React from 'react'

const FormButton = ({ text, onClick, disabled }) => {
  return (
    <button className="primary-button" type="submit" onClick={onClick} disabled={disabled}>
      {text}
    </button>
  )
}

export default FormButton
module.exports = FormButton
