/**
 * TypeaheadInput
 *
 * An accessible, headless combobox built on downshift's useCombobox hook.
 *
 * Props:
 *  source(query, callback)
 *                      — data source function. Called initially and on input value change.
 *  onSelect(item)      — called when user picks a suggestion
 *  onAdd(value)        — called when user presses Enter on a raw typed value (optional)
 *  className           — extra CSS class on the <input>
 *  placeholder         — input placeholder text
 *  defaultValue        — initial input value
 *  inputRef            — ref forwarded to the <input> element
 *  renderSuggestion(item, { isHighlighted, inputValue }) — custom suggestion renderer
 *  classNames          — object of CSS class overrides matching the old typeahead.js classNames config:
 *                        { wrapper, input, menu, suggestion, cursor, hint }
 *  positionRelative    — adds position-relative class to wrapper (mirrors old behaviour)
 *  name                — forwarded to <input> as name attribute
 *  dataAttributes      — extra data-* attributes for the <input>
 *  comboHead           — content above the items
 *  comboFoot           — content below the items
 */

import React, { useCallback, useEffect, useRef, useState } from 'react'
import PropTypes from 'prop-types'
import { useCombobox } from 'downshift'
import cx from 'classnames'
import t from '../../lib/i18n-translate.js'
import { markMatchingFragment } from './typeahead-utils'

const DEFAULT_CLASS_NAMES = {
  wrapper: 'ui-autocomplete-holder',
  input: 'ui-typeahead-input',
  hint: 'ui-autocomplete-hint',
  menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width',
  cursor: 'ui-autocomplete-cursor',
  suggestion: 'ui-menu-item'
}

function TypeaheadInput({
  source,
  onSelect,
  onAdd,
  className,
  placeholder,
  defaultValue,
  inputRef: externalRef,
  renderSuggestion,
  classNames: classNameOverrides,
  positionRelative,
  name,
  dataAttributes = {},
  comboHead,
  comboFoot
}) {
  const classes = { ...DEFAULT_CLASS_NAMES, ...classNameOverrides }

  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(false)
  const updateItems = useCallback(results => {
    setLoading(false)
    setItems(results || [])
  }, [])
  const triggerSource = useCallback(q => {
    setLoading(true)
    source(q, updateItems)
  })

  useEffect(() => {
    triggerSource(defaultValue || '')
  }, [])

  const internalRef = useRef(null)
  const inputElement = externalRef || internalRef

  const getItemString = useCallback(item => {
    if (!item) return '[non-item]'
    if (typeof item === 'string') return item
    return item.label || item.name || item.autocomplete_label || ''
  }, [])

  const {
    isOpen,
    inputValue,
    highlightedIndex,
    getMenuProps,
    getInputProps,
    getItemProps,
    setInputValue
  } = useCombobox({
    items,
    defaultInputValue: defaultValue || '',
    onInputValueChange({ inputValue: query }) {
      const q = query || ''
      triggerSource(q)
    },
    onSelectedItemChange({ selectedItem }) {
      if (selectedItem == null) return
      setInputValue('')
      setItems([])
      onSelect(selectedItem)
    }
  })

  // `onAdd` callback when present is triggered on Enter
  const handleKeyDown = e => {
    if (e.key === 'Enter' && onAdd) {
      const value = inputValue.trim()
      if (value && highlightedIndex === -1) {
        e.preventDefault()
        onAdd(value)
        setInputValue('')
        setItems([])
      }
    }
  }

  const wrapperClass = cx(classes.wrapper, {
    'ui-autocomplete-position-relative': positionRelative
  })

  const showNoResultsMessage = inputValue && items.length === 0
  const hasContent = comboHead || comboFoot || items.length > 0 || showNoResultsMessage
  const showMenu = isOpen && hasContent

  return (
    <div className={wrapperClass} style={{ position: 'relative' }}>
      <input
        ref={inputElement}
        {...getInputProps({
          type: 'text',
          name,
          placeholder,
          className: cx(classes.input, className),
          onKeyDown: handleKeyDown,
          'aria-label': placeholder || name || 'search',
          ...dataAttributes
        })}
      />

      <ul
        {...getMenuProps()}
        className={cx(classes.menu, { hidden: !showMenu, 'tt-open': showMenu })}>
        {loading && (
          <div className="ui-preloader small" style={{ height: '1.5em' }}>
            xxxxxx
          </div>
        )}
        {!loading && showMenu && (
          <>
            {comboHead && <li key="head">{comboHead}</li>}

            {showNoResultsMessage && (
              <li className="ui-autocomplete-empty">{t('app_autocomplete_no_results')}</li>
            )}

            {items.map((item, index) => {
              const isHighlighted = highlightedIndex === index

              let content
              if (renderSuggestion) {
                content = renderSuggestion(item, { isHighlighted, inputValue })
              } else {
                const itemString = getItemString(item)
                content = markMatchingFragment(itemString, inputValue)
              }

              return (
                <li
                  key={index}
                  {...getItemProps({ item, index })}
                  className={cx(
                    classes.suggestion,
                    { [classes.cursor]: isHighlighted },
                    'tt-selectable'
                  )}>
                  {content}
                </li>
              )
            })}

            {comboFoot && <li key="foot">{comboFoot}</li>}
          </>
        )}
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
  renderSuggestion: PropTypes.func,
  classNames: PropTypes.object,
  positionRelative: PropTypes.bool,
  name: PropTypes.string,
  dataAttributes: PropTypes.object,
  comboHead: PropTypes.element,
  comboFoot: PropTypes.element
}

export default TypeaheadInput
