import React, { useState, useEffect } from 'react'

const AutoCompleteWrapper = props => {
  const [AutoComplete, setAutoComplete] = useState(null)

  useEffect(() => {
    import('./autocomplete.jsx').then(({ default: AC }) => {
      setAutoComplete(() => AC)
    })
  }, [])

  return <div>{AutoComplete ? <AutoComplete {...props} /> : null}</div>
}

export default AutoCompleteWrapper
