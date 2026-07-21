import { presence } from '../../lib/present';
import { get, includes } from 'lodash-es';
/**
 * AutoComplete
 *
 * Component that provides search functionality for Resources via the search backend.
 * Wraps TypeaheadInput (downshift-based, no jQuery dependency).
 *
 * Example:
 *   callback = (data) => alert(data.uuid)
 *   <AutoComplete name='foo[person]' resourceType='People' onSelect={callback}/>
 */

import React from 'react'
import PropTypes from 'prop-types'
import TypeaheadInput from './typeahead-input.jsx'
import { cx, t } from './ui.js'
import searchResources from '../../lib/search.js'
import { markMatchingFragment } from './typeahead-utils.js'

class AutoComplete extends React.Component {
  static propTypes = {
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
      minLength: PropTypes.number, // remote search only triggered when search query has at least this many chars (default 1)
      localData: PropTypes.array // data which is shown when search query is blank
    }),
    existingValues: PropTypes.func,
    valueGetter: PropTypes.func,
    valueFilter: PropTypes.func,
    positionRelative: PropTypes.bool,
    existingValueHint: PropTypes.string,
    suggestionRenderer: PropTypes.func
  }

  constructor(props) {
    super(props)
    this._inputRef = React.createRef()

    const { resourceType, searchParams, config } = props
    const conf = Object.assign({ minLength: 1 }, config)

    const resourceTypes = Array.isArray(resourceType) ? resourceType : [resourceType]
    this._searchBackends = resourceTypes.map(rt => {
      const backend = searchResources(rt, searchParams)
      if (!backend) throw new Error(`No search backend for '${rt}'!`)
      return backend
    })
    this._source = this._buildSource()

    this._minLength = conf.minLength
    this._localData = conf.localData
  }

  componentDidMount() {
    if (this.props.autoFocus && this._inputRef.current) {
      this._inputRef.current.focus()
    }
  }

  focus() {
    if (this._inputRef.current) this._inputRef.current.focus()
  }

  _buildSource() {
    // const { existingValues, valueGetter, valueFilter } = this.props
    const backends = this._searchBackends

    return (query, callback) => {
      // apply local static data when no search query is present
      if (this._localData && !query) {
        callback(this._localData)
        return
      }

      // skip backend search when query is too short
      if ((query || '').length < this._minLength) {
        callback([])
        return
      }

      // Compound: fan out to all backends and merge results
      let pending = backends.length
      const all = []
      const done = () => {
        pending--
        if (pending === 0) callback(all)
      }
      backends.forEach(backend => {
        backend.source(query, results => {
          all.push(...(results || []))
          done()
        })
      })
    }
  }

  _renderSuggestion = (item, { isHighlighted, inputValue }) => {
    const { existingValues, valueGetter, valueFilter, existingValueHint, suggestionRenderer } =
      this.props
    const backend = this._searchBackends[0]
    const content = get(item, backend.displayKey)
    const value = valueGetter ? valueGetter(item) : content
    const isDisabled =
      (existingValues && includes(existingValues(), value)) || (valueFilter && valueFilter(item))

    const line = suggestionRenderer ? (
      suggestionRenderer(item, { isHighlighted, inputValue })
    ) : (
      <span>{markMatchingFragment(content, inputValue)}</span>
    )

    if (isDisabled) {
      return (
        <div
          className="ui-autocomplete-disabled"
          title={presence(existingValueHint) || t('meta_data_input_keywords_existing')}>
          {line}
        </div>
      );
    }
    return <div>{line}</div>
  }

  render() {
    const { name, value, placeholder, className, positionRelative, onAddValue } = this.props

    return (
      <TypeaheadInput
        inputRef={this._inputRef}
        name={name}
        defaultValue={value || ''}
        placeholder={placeholder || 'search…'}
        className={cx(className)}
        source={this._source}
        onSelect={this.props.onSelect}
        onAdd={onAddValue}
        positionRelative={positionRelative}
        renderSuggestion={this._renderSuggestion}
        dataAttributes={{ 'data-autocomplete-for': name }}
      />
    )
  }
}

export default AutoComplete
