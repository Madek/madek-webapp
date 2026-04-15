import React from 'react'

export function markMatchingFragment(itemLabel, inputValue) {
  if (!inputValue) return itemLabel

  const escapedInput = inputValue.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const parts = itemLabel.split(new RegExp(`(${escapedInput})`, 'gi'))

  if (parts.length === 1) return itemLabel

  return (
    <>
      {parts.map((part, i) =>
        part.toLowerCase() === inputValue.toLowerCase() ? (
          <b key={i} className="ui-autocomplete__matching-fragment">
            {part}
          </b>
        ) : (
          part
        )
      )}
    </>
  )
}
