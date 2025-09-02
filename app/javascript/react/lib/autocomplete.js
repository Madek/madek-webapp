/**
 * AutoComplete
 *
 * Component that wraps the jQuery.typeahead and provides search functionality
 * for Resources that we have a search backend for.
 *
 * Example:
 * callback = (data) => alert(data.uuid)
 * <AutoComplete name='foo[person]' resourceType='People' onSelect={callback}/>
 *
 * NOTE: fails if even required on server (jQuery)!
 */

import React from 'react'
import createReactClass from 'create-react-class'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import jQuery from 'jquery'
require('@eins78/typeahead.js/dist/typeahead.jquery.js')
import { cx, t } from '../lib/ui.js'
import searchResources from '../../lib/search.js'

const initTypeahead = (
  domNode,
  resourceType,
  params,
  conf,
  existingValues,
  valueGetter,
  valueFilter,
  onSelect,
  onAdd,
  positionRelative,
  existingValueHint,
  suggestionRenderer
) => {
  const { minLength, localData } = conf

  const resourceTypes = Array.isArray(resourceType) ? resourceType : [resourceType]
  const searchBackends = resourceTypes.map(resourceType => {
    const searchBackend = searchResources(resourceType, params, localData)
    if (!searchBackend) {
      throw new Error(`No search backend for '${resourceType}'!`)
    }
    return searchBackend
  })

  const typeaheadConfig = {
    hint: false,
    highlight: true,
    minLength: minLength,
    classNames: {
      wrapper: 'ui-autocomplete-holder',
      input: 'ui-typeahead-input',
      hint: 'ui-autocomplete-hint',
      menu: cx('ui-autocomplete ui-menu ui-autocomplete-open-width', {
        'ui-autocomplete-position-relative': positionRelative
      }),
      cursor: 'ui-autocomplete-cursor',
      suggestion: 'ui-menu-item'
    }
  }

  const notFoundPrefix = searchBackend => {
    if (searchBackends.length > 1) {
      return (searchBackend.displayName || searchBackend.name.split('Search')[0]) + ' - '
    } else {
      return ''
    }
  }

  const dataSets = searchBackends.map(searchBackend => {
    return Object.assign({}, searchBackend, {
      templates: {
        pending: '<div class="ui-preloader small" style="height: 1.5em"></div>',
        notFound: `<div class="ui-autocomplete-empty">${notFoundPrefix(searchBackend)}${t(
          'app_autocomplete_no_results'
        )}</div>`,
        suggestion: record => {
          const content = f.get(record, searchBackend.displayKey)
          const value = valueGetter ? valueGetter(record) : content
          const isDisabled =
            (existingValues && f.includes(existingValues(), value)) ||
            (valueFilter && valueFilter(record))

          const renderLine =
            suggestionRenderer ||
            (() => {
              return jQuery('<span>').text(content)
            })
          const line = renderLine(record)

          const node = jQuery('<div>').append(line)
          if (isDisabled) {
            node.attr({
              class: 'ui-autocomplete-disabled',
              title: f.presence(existingValueHint) || t('meta_data_input_keywords_existing')
            })
          }
          return node
        }
      }
    })
  })

  const $input = jQuery(domNode)
  const typeahead = $input.typeahead(typeaheadConfig, ...dataSets)
  typeahead.on('typeahead:render', function () {
    const container = jQuery(this).closest('.ui-autocomplete-holder')
    container.find('.tt-dataset-CompoundSearch').remove()

    if (
      dataSets.length > 1 &&
      container.find('.ui-autocomplete-empty').length === dataSets.length
    ) {
      container.find('.tt-dataset').empty()
      const dataSetEl = jQuery('<div>').addClass('tt-dataset tt-dataset-CompoundSearch')
      const emptyEl = jQuery('<div>').addClass('ui-autocomplete-empty')
      emptyEl.text(t('app_autocomplete_no_results'))
      container.find('.ui-autocomplete').append(dataSetEl.append(emptyEl))
    }
  })

  typeahead.on('keypress', event => {
    if (event.keyCode === 13) {
      event.preventDefault()
      const value = f.presence($input.typeahead('val'))
      if (value && f.isFunction(onAdd)) {
        onAdd(value)
        $input.typeahead('val', '')
      }
    }

    if (event.keyCode === 27) {
      $input.blur()
    }

    return null
  })

  typeahead.on('typeahead:select typeahead:autocomplete', (event, item) => {
    event.preventDefault()
    $input.typeahead('val', ' ')
    $input.typeahead('val', '')
    onSelect(item)
  })
}

module.exports = createReactClass({
  displayName: 'AutoComplete',
  propTypes: {
    name: PropTypes.string.isRequired,
    resourceType: PropTypes.oneOfType([PropTypes.string, PropTypes.array]).isRequired,
    onSelect: PropTypes.func.isRequired,
    onAddValue: PropTypes.func,
    value: PropTypes.string,
    placeholder: PropTypes.string,
    className: PropTypes.string,
    autoFocus: PropTypes.bool,
    searchParams: PropTypes.object,
    config: PropTypes.shape({
      minLength: PropTypes.number
    }),
    suggestionRenderer: PropTypes.func
  },

  componentDidMount() {
    const {
      resourceType,
      searchParams,
      autoFocus,
      config,
      existingValues,
      valueGetter,
      valueFilter,
      onSelect,
      onAddValue,
      positionRelative,
      existingValueHint,
      suggestionRenderer
    } = this.props
    const conf = Object.assign({ minLength: 1 }, config)
    const inputDOM = ReactDOM.findDOMNode(this.refs.InputField)
    initTypeahead(
      inputDOM,
      resourceType,
      searchParams,
      conf,
      existingValues,
      valueGetter,
      valueFilter,
      onSelect,
      onAddValue,
      positionRelative,
      existingValueHint,
      suggestionRenderer
    )
    if (autoFocus) this.focus()
  },

  focus() {
    jQuery(ReactDOM.findDOMNode(this.refs.InputField)).focus()
  },

  render() {
    const { name, value, placeholder, className } = this.props

    return (
      <input
        ref="InputField"
        type="text"
        className={cx('typeahead', className)}
        defaultValue={value || ''}
        placeholder={placeholder || 'search…'}
        data-autocomplete-for={name}
      />
    )
  }
})
