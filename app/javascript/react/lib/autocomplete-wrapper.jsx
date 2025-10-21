import React, { useState, useEffect } from 'react'

const AutoCompleteWrapper = props => {
  const [AutoComplete, setAutoComplete] = useState(null)

  useEffect(() => {
    const AC = require('./autocomplete.js')
    setAutoComplete(() => AC)
  }, [])

  return <div>{AutoComplete ? <AutoComplete {...props} /> : null}</div>
}

export default AutoCompleteWrapper
module.exports = AutoCompleteWrapper
