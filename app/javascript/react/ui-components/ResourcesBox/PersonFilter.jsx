import React, { Component } from 'react'
import f from 'active-lodash'
import cx from 'classnames'
import t from '../../../lib/i18n-translate.js'
import TypeaheadInput from '../../lib/typeahead-input.jsx'
import { markMatchingFragment } from '../../lib/typeahead-utils.js'
import { createRemoteSource } from '../../../lib/remote-search.js'

export default class PersonFilter extends Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  render() {
    const {
      props: {
        label,
        staticItems,
        className,
        onClear,
        withTitle,
        contextKeyId,
        tooManyHits,
        onSelect,
        jsonPath
      }
    } = this

    const selection = f.filter(staticItems, 'selected')
    const clear = (selected, event) => {
      event.preventDefault()
      onClear(selected)
    }

    const source = tooManyHits
      ? getRemoteSource(staticItems, contextKeyId, jsonPath)
      : getStaticSource(staticItems)

    return (
      <ul className={className}>
        {withTitle && (
          <li key="title" className="ui-side-filter-lvl3-item ptx plm" style={{ fontSize: '12px' }}>
            <strong>{t('dynamic_filters_person_header')}</strong>
          </li>
        )}

        {f.map(selection, selected => (
          <li
            key={'uuid_' + selected.uuid}
            className={cx('ui-side-filter-lvl3-item', { active: true })}>
            <a className="link weak ui-link" onClick={event => clear(selected, event)}>
              {selected.label}
              {selected.label && <span className="ui-lvl3-item-count">{selected.count}</span>}
            </a>
          </li>
        ))}

        <li key="input" className={cx('ui-side-filter-lvl3-item', { mtx: selection.length > 0 })}>
          <TypeaheadInput
            source={source}
            onSelect={item => {
              onSelect(item)
            }}
            placeholder={`${t('dynamic_filters_search_for')} ${label}...`}
            classNames={{
              wrapper: 'ui-autocomplete-holder',
              input: 'ui-typeahead-input block',
              hint: 'ui-autocomplete-hint',
              menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width ui-autocomplete-top-margin-2',
              cursor: 'ui-autocomplete-cursor',
              suggestion: '' // (-> renderSuggestion)
            }}
            renderSuggestion={(value, { /*isHighlighted, */ inputValue }) => (
              <div
                className={cx(
                  'ui-autocomplete-override-sidebar ui-autocomplete-override-sidebar--with-number',
                  { 'ui-autocomplete-disabled': value.disabled }
                )}>
                <div className="ui-autocomplete-override-sidebar__label">
                  {markMatchingFragment(value.label, inputValue)}
                </div>
                <div className="ui-autocomplete-override-sidebar__number">
                  {value.count === undefined ? '' : value.count}
                </div>
              </div>
            )}
            comboFoot={
              tooManyHits && (
                <div className="ui-autocomplete-footer">{t('app_autocomplete_enter_term')}</div>
              )
            }
          />
        </li>
      </ul>
    )
  }
}

// helpers

const maxHits = 10

function getStaticSource(staticItems) {
  return (term, callback) => {
    const isMatch =
      term.length === 0 ? () => true : u => u.label.toLowerCase().includes(term.toLowerCase())
    callback(f.filter(staticItems, user => !user.selected && isMatch(user)))
  }
}

function getRemoteSource(staticItems, contextKeyId, jsonPath) {
  const getUrl = () => {
    const url = new URL(location.href)
    url.searchParams.set('list[sparse_filter]', 'true')
    url.searchParams.set('___sparse', JSON.stringify(f.set({}, jsonPath, {})))
    url.searchParams.set('context_key_id', contextKeyId)
    url.searchParams.set('search_term', '__SEARCH_TERM__')
    return url.href
  }

  // Cache the source instance — only created once per render cycle
  let _remoteSource = null

  return (query, callback) => {
    if (!_remoteSource) {
      _remoteSource = createRemoteSource(getUrl(), {
        wildcard: '__SEARCH_TERM__',
        local: staticItems.map(x => ({ ...x, tooManyHits: true, local: true })),
        transform: data => {
          const contextKeys = f.get(data, jsonPath)
          if (!contextKeys) return []
          const flat = contextKeys.flatMap(x => x.children)
          if (flat.length === 0) return []
          const results = [...flat[0].children.filter(x => x.type === 'person')]
          if (results.length > 0) {
            results[0].tooManyHits = flat[0].too_many_hits
            // Update footer visibility
            setTimeout(() => {
              const footer = document.querySelector('.ui-autocomplete-footer')
              if (footer) {
                footer.style.display = results[0].tooManyHits ? 'block' : 'none'
                footer.textContent = t('app_autocomplete_extend_term')
              }
            }, 5)
          }
          return results
        }
      })
    }

    if (!query) {
      // Return local unselected items immediately
      callback(staticItems.filter(x => !x.selected).slice(0, maxHits))
    } else {
      _remoteSource(query, callback)
    }
  }
}
