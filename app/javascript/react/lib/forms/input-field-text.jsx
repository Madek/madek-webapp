import React from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import { useCombobox } from 'downshift'
import { markMatchingFragment } from '../typeahead-utils'

const InputFieldText = props => {
  const { name, type, value, placeholder, className, metaKey, onChange, batch } = props

  const { defaultText, suggestions } = getDefaultTextAndSuggestionsFor(metaKey)
  const defaultValue = batch ? '' : defaultText

  if (suggestions.length > 0) {
    return (
      <InputWithSuggestions
        name={name}
        value={value}
        defaultValue={defaultValue}
        placeholder={placeholder}
        className={className}
        onChange={onChange}
        suggestions={suggestions}
      />
    )
  } else {
    const Element = metaKey && metaKey.text_type === 'block' ? 'textarea' : 'input'
    const commonProps = {
      name,
      onChange,
      placeholder,
      className: cx(className, 'block')
    }
    return (
      <Element
        type={type || 'text'}
        defaultValue={value || defaultValue}
        style={{
          textIndent: '0em',
          paddingLeft: '8px'
        }}
        {...commonProps}
      />
    )
  }
}

function getDefaultTextAndSuggestionsFor(metaKey) {
  if (!metaKey || metaKey.uuid !== 'madek_core:copyright_notice') {
    return { defaultText: undefined, suggestions: [] }
  }
  const defaultText = metaKey.copyright_notice_default_text
  const suggestions = [defaultText, ...(metaKey.copyright_notice_templates || [])].filter(Boolean)
  return { defaultText, suggestions }
}

const InputWithSuggestions = ({
  name,
  value,
  defaultValue,
  placeholder,
  className,
  onChange,
  suggestions
}) => {
  const { isOpen, highlightedIndex, getMenuProps, getInputProps, getItemProps, inputValue } =
    useCombobox({
      items: suggestions,
      itemToString: item => item || '',
      defaultInputValue: value || defaultValue || '',
      onSelectedItemChange({ selectedItem }) {
        if (selectedItem == null) return
        if (onChange) onChange({ target: { value: selectedItem } })
      }
    })

  return (
    <div
      className="ui-autocomplete-holder ui-autocomplete-position-relative"
      style={{ position: 'relative' }}>
      <input
        {...getInputProps({
          type: 'text',
          name,
          placeholder,
          className: cx(className, 'block', 'ui-typeahead-input'),
          'aria-label': placeholder || name || 'search',
          'data-autocomplete-for': name
        })}
      />
      <ul
        {...getMenuProps()}
        className={cx('ui-autocomplete', 'ui-menu', 'ui-autocomplete-open-width', {
          hidden: !isOpen || suggestions.length === 0,
          'tt-open': isOpen
        })}
        style={{ display: isOpen && suggestions.length > 0 ? undefined : 'none' }}>
        {isOpen &&
          suggestions.map((item, index) => (
            <li
              key={index}
              {...getItemProps({ item, index })}
              className={cx(
                'ui-menu-item',
                {
                  'ui-autocomplete-cursor': highlightedIndex === index
                },
                'tt-selectable'
              )}>
              {markMatchingFragment(item, inputValue)}
            </li>
          ))}
      </ul>
    </div>
  )
}

InputFieldText.propTypes = {
  name: PropTypes.string,
  type: PropTypes.string,
  value: PropTypes.string,
  placeholder: PropTypes.string,
  className: PropTypes.string,
  onChange: PropTypes.func
}

export default InputFieldText
