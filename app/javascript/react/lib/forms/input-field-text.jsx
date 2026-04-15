import React, { useRef, useEffect } from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import { get } from '../../../lib/utils.js'
import TypeaheadInput from '../typeahead-input.jsx'

const InputFieldText = props => {
  const { name, type, value, placeholder, className, metaKey, onChange, batch } = props

  const suggestions = () => {
    const defaultText = get(metaKey, 'copyright_notice_default_text', '')
    const templates = get(metaKey, 'copyright_notice_templates', [])
    return [defaultText, ...templates].filter(Boolean)
  }

  const isCopyrightField = get(metaKey, 'uuid', null) === 'madek_core:copyright_notice'

  const Element =
    metaKey && metaKey.text_type && metaKey.text_type === 'block' ? 'textarea' : 'input'

  const style = {
    textIndent: '0em',
    paddingLeft: '8px'
  }

  const commonProps = {
    name,
    placeholder,
    className: cx(className, 'block')
  }

  if (onChange) {
    commonProps.onChange = onChange
  }

  if (isCopyrightField) {
    const defaultValue = batch ? '' : get(metaKey, 'copyright_notice_default_text', '')

    // Sync-only source: returns suggestion strings from metaKey templates
    const source = (query, syncCallback) => {
      const all = suggestions()
      if (!query) {
        syncCallback(all)
      } else {
        syncCallback(all.filter(s => s.toLowerCase().includes(query.toLowerCase())))
      }
    }

    const handleSelect = item => {
      if (onChange) onChange({ target: { value: item } })
    }

    return (
      <TypeaheadInput
        name={name}
        defaultValue={value || defaultValue}
        placeholder={placeholder}
        className={cx(className, 'block')}
        source={source}
        onSelect={handleSelect}
        minLength={0}
        highlight={true}
        itemToString={item => item || ''}
        classNames={{
          wrapper: 'ui-autocomplete-holder ui-autocomplete-position-relative',
          input: 'ui-typeahead-input',
          hint: 'ui-autocomplete-hint',
          menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width',
          cursor: 'ui-autocomplete-cursor',
          suggestion: 'ui-menu-item'
        }}
        dataAttributes={{ 'data-autocomplete-for': name }}
      />
    )
  }

  return <Element type={type || 'text'} defaultValue={value || ''} style={style} {...commonProps} />
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
module.exports = InputFieldText
