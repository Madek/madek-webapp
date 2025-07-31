import React from 'react'

export default function SelectingTextarea(props) {
  const doSelect = event => {
    const { target } = event
    setTimeout(() => {
      // NOTE: Mobile Safari does not support `select()`, use this fallback:
      let selectionLength
      try {
        selectionLength = target.value.length

        // eslint-disable-next-line no-unused-vars
      } catch (e) {
        selectionLength = 9999
      }
      target.setSelectionRange(0, selectionLength)
      target.focus()
    }, 1)
  }
  return (
    <textarea
      rows="4"
      {...props}
      value={props.value || props.children}
      style={{
        display: 'inline-block',
        textIndent: 0,
        fontSize: '85%',
        minHeight: '3em',
        ...props.style
      }}
      onClick={doSelect}
      onFocus={doSelect}
      onChange={doSelect}
    />
  )
}
