import React, { useRef, useEffect } from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import jQuery from 'jquery'
import { get } from '../../../lib/utils.js'

const InputFieldText = props => {
  const { name, type, value, placeholder, className, metaKey, onChange } = props
  const inputRef = useRef(null)

  useEffect(() => {
    if (inputRef.current) {
      initSuggestions()
    }
  }, [])

  const initSuggestions = () => {
    require('@eins78/typeahead.js/dist/typeahead.jquery.js')

    const $input = jQuery(inputRef.current)
    $input.typeahead(
      {
        minLength: 0,
        highlight: true,
        classNames: {
          // madek style:
          wrapper: 'ui-autocomplete-holder ui-autocomplete-position-relative',
          input: 'ui-typeahead-input',
          hint: 'ui-autocomplete-hint',
          menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width',
          cursor: 'ui-autocomplete-cursor',
          suggestion: 'ui-menu-item'
        }
      },
      {
        name: 'templates',
        source: (query, syncResults) => {
          return syncResults(suggestions())
        }
      }
    )
    if (onChange) {
      $input.on('typeahead:select', event => onChange(event))
    }
  }

  const suggestions = () => {
    const defaultText = get(metaKey, 'copyright_notice_default_text', '')
    const templates = get(metaKey, 'copyright_notice_templates', [])
    return [defaultText, ...templates].filter(Boolean)
  }

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

  if (get(metaKey, 'uuid', null) === 'madek_core:copyright_notice') {
    const defaultValue = get(metaKey, 'copyright_notice_default_text', '')

    return (
      <input
        ref={inputRef}
        type="text"
        defaultValue={value || defaultValue}
        data-autocomplete-for={name}
        {...commonProps}
      />
    )
  } else {
    return (
      <Element type={type || 'text'} defaultValue={value || ''} style={style} {...commonProps} />
    )
  }
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
