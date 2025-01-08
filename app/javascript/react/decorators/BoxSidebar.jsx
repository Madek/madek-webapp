import React from 'react'
import l from 'lodash'
import Preloader from '../ui-components/Preloader.jsx'
import Button from '../ui-components/Button.jsx'
import Link from '../ui-components/Link.jsx'
import SideFilter from '../ui-components/ResourcesBox/SideFilter.jsx'
import RailsForm from '../lib/forms/rails-form.jsx'
import setUrlParams from '../../lib/set-params-for-url.js'
import t from '../../lib/i18n-translate.js'
import { urlByType } from '../lib/resource-type-switcher.jsx'

class BoxSidebar extends React.Component {
  constructor(props) {
    super(props)
  }

  has_filename_filter() {
    var config = this.props.config
    return (
      config.filter &&
      config.filter.media_files &&
      !l.isEmpty(
        l.filter(config.filter.media_files, entry => {
          entry.key == 'filename'
        })
      )
    )
  }

  filename_filter_string() {
    var config = this.props.config
    return l.first(
      l.filter(config.filter.media_files, entry => {
        entry.key == 'filename'
      })
    ).value
  }

  fulltext_filter_string() {
    var config = this.props.config
    if (config.filter) return config.filter.search
    else return ''
  }

  filterExamples() {
    return {
      "Search: 'still'": {
        search: 'still',
        isAllowedForType: () => true
      },
      "Title: 'diplom'": {
        meta_data: [{ key: 'madek_core:title', match: 'diplom' }],
        isAllowedForType: t => t !== 'all'
      },
      "Uses Meta-Key 'Gattung'": {
        meta_data: [{ key: 'media_content:type' }],
        isAllowedForType: t => t !== 'all'
      },
      'Permissions: public': {
        permissions: [{ key: 'visibility', value: 'public' }],
        isAllowedForType: t => t !== 'all'
      },
      'Media File: Content-Type jpeg': {
        media_files: [{ key: 'content_type', value: 'image/jpeg' }],
        isAllowedForType: t => t === 'entries'
      },
      'Media File: Extension pdf': {
        media_files: [{ key: 'extension', value: 'pdf' }],
        isAllowedForType: t => t === 'entries'
      }
    }
  }

  renderFilterPreloader() {
    return (
      <div className="ui-slide-filter-item">
        <div className="title-xs by-center">Filter werden geladen</div>
        <Preloader mods="small" />
      </div>
    )
  }

  renderFilterExamples() {
    const url = this.props.config.for_url
    const type = url.query.type || 'all'
    const query = this.props.currentQuery
    const examples = this.filterExamples()

    return (
      <div>
        <h4>Examples:</h4>
        <ul>
          {Object.entries(examples)
            .filter(([, example]) => example.isAllowedForType(type))
            .map(([name, example]) => {
              var params = { list: { page: 1, filter: JSON.stringify(example, 0, 2) } }
              return (
                <li key={name}>
                  <Link href={setUrlParams(url, query, params)} rel="nofollow">
                    {name}
                  </Link>
                </li>
              )
            })}
        </ul>
      </div>
    )
  }

  renderSideFilterFallback() {
    var filter = this.props.config.filter
    filter = filter ? filter : {}
    return (
      <div className="ui-side-filter-search filter-search">
        <RailsForm name="list" method="get" mods="prm">
          <input type="hidden" name="list[show_filter]" value="true" />
          <textarea
            name="list[filter]"
            rows="25"
            style={{ fontFamily: 'monospace', fontSize: '1.1em', width: '100%' }}
            defaultValue={JSON.stringify(filter, 0, 2)}
          />
          <Button type="submit">Submit</Button>
        </RailsForm>
      </div>
    )
  }

  renderNoJs() {
    var config = this.props.config
    var currentQuery = this.props.currentQuery
    return (
      <div>
        <div className="no-js">
          {this.renderSideFilterFallback()}
          {this.renderFilterExamples()}
        </div>
        <div className="js-only">{this.renderFilterPreloader()}</div>
      </div>
    )
  }

  searchValue() {
    if (this.has_filename_filter()) {
      return this.filename_filter_string()
    } else {
      return this.fulltext_filter_string()
    }
  }

  renderFilesearch() {
    if (!this.props.supportsFilesearch) {
      return null
    }

    return (
      <div style={{ marginTop: '2px' }}>
        <input
          ref="searchTypeFulltext"
          type="radio"
          name="search_type"
          value="fulltext"
          defaultChecked={!this.has_filename_filter()}
        />
        {' ' + t('search_full_text') + ' '}
        <input
          ref="searchTypeFilename"
          type="radio"
          name="search_type"
          value="filename"
          defaultChecked={this.has_filename_filter()}
        />
        {' ' + t('search_filename')}
      </div>
    )
  }

  renderSideFilter() {
    if (this.props.onlyFilterSearch) {
      return null
    }

    return (
      <SideFilter
        forUrl={this.props.parentState.config.for_url}
        jsonPath={this.props.jsonPath}
        current={this.props.config.filter ? this.props.config.filter : {}}
        accordion={this.props.config.accordion ? this.props.config.accordion : {}}
        onChange={this.props.onSideFilterChange}
      />
    )
  }

  _onSearch(event) {
    var refs = this.refs

    var searchTypeFulltextChecked = refs.searchTypeFulltext ? refs.searchTypeFulltext.checked : null
    var searchTypeFilenameChecked = refs.searchTypeFilename ? refs.searchTypeFilename.checked : null
    var filterSearchValue = refs.filterSearch.value
    this.props.onSearch(event, {
      searchTypeFulltextChecked: searchTypeFulltextChecked,
      searchTypeFilenameChecked: searchTypeFilenameChecked,
      filterSearchValue: filterSearchValue
    })
  }

  renderJs() {
    return (
      <div className="js-only">
        <div className="ui-side-filter-search filter-search">
          <form name="filter_search_form" onSubmit={e => this._onSearch(e)}>
            <input type="submit" className="unstyled" value={t('resources_box_new_search')} />
            <input
              type="text"
              className="ui-filter-search-input block"
              ref="filterSearch"
              defaultValue={this.searchValue()}
            />
            {this.renderFilesearch()}
          </form>
        </div>
        {this.renderSideFilter()}
      </div>
    )
  }

  renderJsSwitch() {
    if (!this.props.isClient) {
      return this.renderNoJs()
    } else {
      return this.renderJs()
    }
  }

  renderFiltersNote() {
    const { currentUrl, parentState } = this.props

    if (l.get(parentState, 'boxState.props.get.content_type') !== 'MediaResource') {
      return null
    }

    return (
      <div className="mtm">
        {t('resources_box_filters_note_pre')}{' '}
        <Link href={urlByType(currentUrl, null, 'entries')}>{t('sitemap_entries')}</Link>{' '}
        {t('resources_box_filters_note_or')}{' '}
        <Link href={urlByType(currentUrl, null, 'collections')}>{t('sitemap_collections')}</Link>{' '}
        {t('resources_box_filters_note_post')}
      </div>
    )
  }

  render() {
    return (
      <div className="filter-panel ui-side-filter">
        {this.renderJsSwitch()}
        {this.renderFiltersNote()}
      </div>
    )
  }
}

module.exports = BoxSidebar
