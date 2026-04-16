/**
 * TypeaheadInput
 *
 * An accessible, headless combobox built on downshift's useCombobox hook.
 * Replaces the jQuery typeahead.js plugin throughout the app.
 *
 * Props:
 *  source(query, syncCallback, asyncCallback) — data source function (same interface as Bloodhound)
 *  onSelect(item)      — called when user picks a suggestion
 *  onAdd(value)        — called when user presses Enter on a raw typed value (optional)
 *  className           — extra CSS class on the <input>
 *  placeholder         — input placeholder text
 *  defaultValue        — initial input value
 *  inputRef            — ref forwarded to the <input> element
 *  minLength           — minimum chars before source is called (default 1)
 *  highlight           — highlight matched text in suggestions (default true)
 *  itemToString(item)  — converts item to display string (default: item itself for strings)
 *  renderSuggestion(item, { isHighlighted, inputValue }) — custom suggestion renderer
 *  classNames          — object of CSS class overrides matching the old typeahead.js classNames config:
 *                        { wrapper, input, menu, suggestion, cursor, hint }
 *  positionRelative    — adds position-relative class to wrapper (mirrors old behaviour)
 *  name                — forwarded to <input> as name attribute
 *  dataAttributes      — extra data-* attributes for the <input>
 */

import React, { useCallback, useEffect, useRef, useState } from 'react'
import PropTypes from 'prop-types'
import { useCombobox } from 'downshift'
import cx from 'classnames'

const DEFAULT_CLASS_NAMES = {
  wrapper: 'ui-autocomplete-holder',
  input: 'ui-typeahead-input',
  hint: 'ui-autocomplete-hint',
  menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width',
  cursor: 'ui-autocomplete-cursor',
  suggestion: 'ui-menu-item'
}

function highlightMatch(text, query) {
  if (!query || !text) return text
  const idx = String(text).toLowerCase().indexOf(query.toLowerCase())
  if (idx === -1) return text
  const before = String(text).slice(0, idx)
  const match = String(text).slice(idx, idx + query.length)
  const after = String(text).slice(idx + query.length)
  return (
    <>
      {before}
      <strong>{match}</strong>
      {after}
    </>
  )
}

function TypeaheadInput({
  source,
  onSelect,
  onAdd,
  className,
  placeholder,
  defaultValue,
  inputRef: externalRef,
  minLength = 1,
  highlight = true,
  itemToString,
  renderSuggestion,
  classNames: classNameOverrides,
  positionRelative,
  name,
  dataAttributes = {}
}) {
  const classes = { ...DEFAULT_CLASS_NAMES, ...classNameOverrides }
  const [items, setItems] = useState([])
  const internalRef = useRef(null)
  const inputElement = externalRef || internalRef

  const resolveItemToString = useCallback(
    item => {
      if (itemToString) return itemToString(item) || ''
      if (!item) return ''
      if (typeof item === 'string') return item
      return item.label || item.name || item.autocomplete_label || ''
    },
    [itemToString]
  )

  const {
    isOpen,
    inputValue,
    highlightedIndex,
    getMenuProps,
    getInputProps,
    getItemProps,
    setInputValue,
    openMenu,
    closeMenu
  } = useCombobox({
    items,
    itemToString: resolveItemToString,
    defaultInputValue: defaultValue || '',
    onInputValueChange({ inputValue: query }) {
      const q = query || ''
      if (q.length < minLength) {
        if (minLength > 0) {
          setItems([])
          return
        }
      }
      const syncResults = results => setItems(results || [])
      const asyncResults = results => setItems(results || [])
      source(q, syncResults, asyncResults)
    },
    onSelectedItemChange({ selectedItem }) {
      if (selectedItem == null) return
      setInputValue('')
      setItems([])
      onSelect(selectedItem)
    },
    stateReducer(state, actionAndChanges) {
      const { changes, type } = actionAndChanges
      // Prevent clearing the input when the menu closes after selection —
      // we handle that ourselves in onSelectedItemChange.
      if (type === useCombobox.stateChangeTypes.InputBlur) {
        return { ...changes, inputValue: state.inputValue }
      }
      return changes
    }
  })

  // When minLength === 0, show all suggestions on focus
  const handleFocus = () => {
    if (minLength === 0 && !isOpen) {
      const syncResults = results => setItems(results || [])
      const asyncResults = results => setItems(results || [])
      source('', syncResults, asyncResults)
      openMenu()
    }
  }

  // Handle Enter (onAdd) and Escape keyboard events not covered by downshift
  const handleKeyDown = e => {
    if (e.key === 'Enter' && onAdd) {
      const value = inputValue.trim()
      if (value && highlightedIndex === -1) {
        e.preventDefault()
        onAdd(value)
        setInputValue('')
        setItems([])
        closeMenu()
      }
    }
    if (e.key === 'Escape') {
      inputElement.current && inputElement.current.blur()
    }
  }

  // Expose a focus() method via the ref for callers like AutoComplete
  useEffect(() => {
    if (externalRef && inputElement.current) {
      // allow parent to call inputElement.current.focus()
    }
  }, [externalRef, inputElement])

  const wrapperClass = cx(classes.wrapper, {
    'ui-autocomplete-position-relative': positionRelative
  })

  return (
    <div className={wrapperClass} style={{ position: 'relative' }}>
      <input
        {...getInputProps({
          ref: inputElement,
          type: 'text',
          name,
          placeholder,
          className: cx(classes.input, className),
          onFocus: handleFocus,
          onKeyDown: handleKeyDown,
          'aria-label': placeholder || name || 'search',
          ...dataAttributes
        })}
      />

      <ul
        {...getMenuProps()}
        className={cx(classes.menu, { hidden: !isOpen || items.length === 0 })}
        style={{ display: isOpen && items.length > 0 ? undefined : 'none' }}>
        {isOpen &&
          items.map((item, index) => {
            const isHighlighted = highlightedIndex === index
            const itemStr = resolveItemToString(item)

            let content
            if (renderSuggestion) {
              content = renderSuggestion(item, { isHighlighted, inputValue })
            } else if (highlight) {
              content = highlightMatch(itemStr, inputValue)
            } else {
              content = itemStr
            }

            return (
              <li
                key={index}
                {...getItemProps({ item, index })}
                className={cx(classes.suggestion, { [classes.cursor]: isHighlighted })}>
                {content}
              </li>
            )
          })}
      </ul>
    </div>
  )
}

TypeaheadInput.propTypes = {
  source: PropTypes.func.isRequired,
  onSelect: PropTypes.func.isRequired,
  onAdd: PropTypes.func,
  className: PropTypes.string,
  placeholder: PropTypes.string,
  defaultValue: PropTypes.string,
  inputRef: PropTypes.object,
  minLength: PropTypes.number,
  highlight: PropTypes.bool,
  itemToString: PropTypes.func,
  renderSuggestion: PropTypes.func,
  classNames: PropTypes.object,
  positionRelative: PropTypes.bool,
  name: PropTypes.string,
  dataAttributes: PropTypes.object
}

export default TypeaheadInput
module.exports = TypeaheadInput
