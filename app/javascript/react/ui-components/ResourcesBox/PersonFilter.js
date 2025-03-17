import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import cx from 'classnames'
import jQuery from 'jquery'
import t from '../../../lib/i18n-translate'

export default class PersonFilter extends Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  componentDidMount() {
    const {
      inputField,
      props: { contextKeyId, staticItems, tooManyHits, onSelect, jsonPath }
    } = this
    const typeaheadOptions = getTypeaheadOptions()
    const dataSet = getDataSet(contextKeyId, staticItems, tooManyHits, jsonPath)

    const domNode = ReactDOM.findDOMNode(inputField)
    const jqNode = jQuery(domNode)
    require('@eins78/typeahead.js/dist/typeahead.jquery.js') // NOTE: do not convert this into a ES6 import (it will crash SSR)
    const typeahead = jqNode.typeahead(typeaheadOptions, dataSet)

    typeahead.on('typeahead:select typeahead:autocomplete', (event, item) => {
      event.preventDefault()
      jqNode.typeahead('val', '')
      onSelect(item)
    })
  }

  render() {
    const {
      props: { label, staticItems, className, onClear, withTitle }
    } = this

    const selection = f.filter(staticItems, 'selected')
    const clear = (selected, event) => {
      event.preventDefault()
      onClear(selected)
    }

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
          <div style={{ position: 'relative' }}>
            <input
              ref={el => (this.inputField = el)}
              type="text"
              placeholder={`${t('dynamic_filters_search_for')} ${label}...`}
              className="typeahead block"
            />
          </div>
        </li>
      </ul>
    )
  }
}

// typeahead plumbing

const maxHits = 10

function getTypeaheadOptions() {
  return {
    hint: false,
    highlight: true,
    minLength: 0,
    classNames: {
      wrapper: 'ui-autocomplete-holder',
      input: 'ui-typeahead-input',
      hint: 'ui-autocomplete-hint',
      menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width ui-autocomplete-top-margin-2',
      cursor: 'ui-autocomplete-cursor',
      suggestion: 'ui-menu-item'
    }
  }
}

function getStaticDataSource(staticItems) {
  return (term, callback) => {
    const isMatch =
      term.length === 0 ? () => true : u => u.label.toLowerCase().indexOf(term.toLowerCase()) >= 0
    const result = f.filter(staticItems, user => !user.selected && isMatch(user))
    callback(result)
  }
}

function getRemoteDataSource(staticItems, contextKeyId, jsonPath) {
  const getHref = () => {
    const url = new URL(location.href)
    url.searchParams.set('list[sparse_filter]', 'true')
    url.searchParams.set('___sparse', JSON.stringify(f.set({}, jsonPath, {})))
    url.searchParams.set('context_key_id', contextKeyId)
    url.searchParams.set('search_term', '__SEARCH_TERM__')
    return url.href
  }

  const Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js') // NOTE: do not convert this into a ES6 import (it will crash SSR)
  const tokenizer = s => {
    const label = s.label ? s.label : s
    return Bloodhound.tokenizers.whitespace((label || '').trim())
  }
  const bloodhound = new Bloodhound({
    datumTokenizer: tokenizer,
    queryTokenizer: tokenizer,
    local: staticItems.map(x => ({ ...x, tooManyHits: true, local: true })),
    identify: x => x.uuid,
    sufficient: maxHits + 1, // to force re-fetch when local data is present
    remote: {
      url: getHref(),
      wildcard: '__SEARCH_TERM__',
      transform: data => {
        const contextKeys = f.get(data, jsonPath).flatMap(x => x.children)
        if (contextKeys.length === 0) {
          return []
        }
        const results = [...contextKeys[0].children.filter(x => x.type === 'person')]
        results[0].tooManyHits = contextKeys[0].too_many_hits

        // Show/hide footer with "too many hits" hint (see explanation below why this can not be done in `footer` hook)
        // A delay is needed because the footer is gone then the result list is temporarily empty
        // after all initial local hits are filtered away.
        setTimeout(() => {
          const footer = document.querySelector('.ui-autocomplete-footer')
          if (footer) {
            footer.style.display = results[0].tooManyHits ? 'block' : 'none'
            footer.textContent = t('app_autocomplete_extend_term')
          }
        }, 5)

        return results
      },
      prepare: (query, settings) => {
        // Show waiting state for mixed local/remote data
        const footer = document.querySelector('.ui-autocomplete-footer')
        if (footer) {
          footer.innerHTML = '<div class="ui-preloader small" style="height: 1.5em"></div>'
        }

        // Implementation detail leak of bloodhound...
        settings.url = settings.url.replace('__SEARCH_TERM__', encodeURIComponent(query))
        return settings
      }
    }
  })
  return (query, sync, async) => {
    if (query === '') {
      // use local data immediately
      sync(bloodhound.index.all())
    } else {
      bloodhound.search(query, sync, async)
    }
  }
}

function getDataSet(contextKeyId, staticItems, tooManyHits, jsonPath) {
  return {
    name: 'people',
    templates: {
      pending: '<div class="ui-preloader small" style="height: 1.5em"></div>',
      notFound: '<div class="ui-autocomplete-empty">' + t('app_autocomplete_no_results') + '</div>',
      suggestion: value =>
        `<div class="${cx(
          'ui-autocomplete-override-sidebar ui-autocomplete-override-sidebar--with-number',
          { 'ui-autocomplete-disabled': value.disabled }
        )}">` +
        `<div class="ui-autocomplete-override-sidebar__label">${escapeHTML(value.label)}</div>` +
        `<div class="ui-autocomplete-override-sidebar__number">${
          value.count === undefined ? '' : value.count
        }<div>` +
        `</div>`,
      footer: () => {
        if (tooManyHits) {
          return `<div class="ui-autocomplete-footer">${t('app_autocomplete_enter_term')}</div>`
        }
        // Note: due to the strange behaviour of typeahead.js and/or bloodhound, this function will not see remote-fetched items
        // when any local items are present in the search result. Thus we can not detect the presence of such
        // in this hook. Instead we use the `prepare` and `transform` hooks in bloodhound config (see above)
      }
    },
    limit: maxHits,
    source: tooManyHits
      ? getRemoteDataSource(staticItems, contextKeyId, jsonPath)
      : getStaticDataSource(staticItems)
  }
}

const escapeHTML = str =>
  str.replace(
    /[&<>'"]/g,
    tag =>
      ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        "'": '&#39;',
        '"': '&quot;'
      })[tag]
  )
