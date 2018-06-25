import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import ResourceThumbnail from './ResourceThumbnail.cjsx'
import Preloader from '../ui-components/Preloader.cjsx'
import Button from '../ui-components/Button.cjsx'
import Link from '../ui-components/Link.cjsx'
import SideFilter from '../ui-components/ResourcesBox/SideFilter.cjsx'
import RailsForm from '../lib/forms/rails-form.cjsx'
import setUrlParams from '../../lib/set-params-for-url.coffee'
import t from '../../lib/i18n-translate.js'

class BoxSidebar extends React.Component {

  constructor(props) {
    super(props)
  }

  has_filename_filter() {
    var config = this.props.config
    return (config.filter &&
      config.filter.media_files &&
      !l.isEmpty(l.filter(config.filter.media_files, (entry) => {
        entry.key == 'filename'
      }))
    )
  }

  filename_filter_string() {
    var config = this.props.config
    return l.first(l.filter(config.filter.media_files, (entry) => {
      entry.key == 'filename'
    })).value
  }

  fulltext_filter_string() {
    var config = this.props.config
    if(config.filter)
      return config.filter.search
    else
      return ''
  }

  filterExamples() {
    return {
      "Search: 'still'": {
        "search": "still"
      },
      "Title: 'diplom'": {
        "meta_data": [{ "key": "madek_core:title", "match": "diplom" }]
      },
      "Uses Meta-Key 'Gattung'": {
        "meta_data": [ { "key": "media_content:type" } ]
      },
      "Permissions: public": {
        "permissions": [{ "key": "public", "value": true }]
      },
      "Media File: Content-Type jpeg": {
        "media_files": [{ "key": "content_type", "value": "image/jpeg" }]
      },
      "Media File: Extension pdf": {
        "media_files": [{ "key": "extension", "value": "pdf" }]
      }
    }
  }

  renderFilterPreloader() {
    return (
      <div className='ui-slide-filter-item'>
        <div className='title-xs by-center'>
          Filter werden geladen</div>
          <Preloader mods='small'/>
      </div>
    )
  }

  renderFilterExamples() {

    var url = this.props.config.for_url
    var query = this.props.currentQuery

    return (
      <div>
        <h4>Examples:</h4>
        <ul>
          {
            l.map(
              this.filterExamples(),
              (example, name) => {
                var params = {list: {page: 1, filter: JSON.stringify(example, 0, 2)}}
                return (
                  <li key={name}>
                    <Link href={setUrlParams(url, query, params)}>{name}</Link>
                  </li>
                )
              }
            )
          }
        </ul>
      </div>
    )
  }

  renderSideFilterFallback() {
    var filter = this.props.config.filter
    filter = (filter ? filter : {})
    return (
      <div className='ui-side-filter-search filter-search'>
        <RailsForm name='list' method='get' mods='prm'>
          <input type='hidden' name='list[show_filter]' value='true'/>
          <textarea name='list[filter]' rows='25'
            style={{fontFamily: 'monospace', fontSize: '1.1em', width: '100%'}}
            defaultValue={JSON.stringify(filter, 0, 2)}/>
          <Button type='submit'>Submit</Button>
        </RailsForm>
      </div>
    )
  }

  renderNoJs() {
    var config = this.props.config
    var currentQuery = this.props.currentQuery
    return (
      <div>
        <div className='no-js'>
          {this.renderSideFilterFallback()}
          {this.renderFilterExamples()}
        </div>
        <div className='js-only'>
          {this.renderFilterPreloader()}
        </div>
      </div>
    )
  }

  searchValue() {
    if(this.has_filename_filter()) {
      return this.filename_filter_string()
    } else {
      return this.fulltext_filter_string()
    }

  }

  renderFilesearch() {
    if(!this.props.supportsFilesearch) {
      return null
    }

    return (
      <div style={{marginTop: '2px'}}>
        <input ref='searchTypeFulltext' type='radio' name='search_type'
          value='fulltext' defaultChecked={(!this.has_filename_filter())} />
        {' ' + t('search_full_text') + ' '}
        <input ref='searchTypeFilename' type='radio' name='search_type'
          value='filename' defaultChecked={this.has_filename_filter()} />
        {' ' + t('search_filename')}
      </div>
    )
  }

  renderSideFilter() {

    if(this.props.onlyFilterSearch) {
      return null
    }

    return (
      <SideFilter
        forUrl={this.props.parentState.config.for_url}
        jsonPath={this.props.jsonPath}
        current={(this.props.config.filter ? this.props.config.filter : {})}
        accordion={(this.props.config.accordion ? this.props.config.accordion : {})}
        onChange={this.props.onSideFilterChange}
      />
    )
  }


  _onSearch(event) {
    var refs = this.refs

    var searchTypeFulltextChecked = refs.searchTypeFulltext.checked
    var searchTypeFilenameChecked = refs.searchTypeFilename.checked
    var filterSearchValue = refs.filterSearch.value
    this.props.onSearch(
      event,
      {
        searchTypeFulltextChecked: searchTypeFulltextChecked,
        searchTypeFilenameChecked: searchTypeFilenameChecked,
        filterSearchValue: filterSearchValue
      }
    )
  }

  renderJs() {
    return (
      <div className='js-only'>
        <div className='ui-side-filter-search filter-search'>
          <form name='filter_search_form' onSubmit={(e) => this._onSearch(e)}>
            <input type='submit' className='unstyled'
              value={t('resources_box_new_search')} />
            <input type='text' className='ui-filter-search-input block'
              ref='filterSearch'
              defaultValue={this.searchValue()}/>
            {this.renderFilesearch()}
          </form>
        </div>
        {this.renderSideFilter()}
      </div>
    )
  }

  renderJsSwitch() {
    if(!this.props.isClient) {
      return this.renderNoJs()
    } else {
      return this.renderJs()
    }
  }

  render() {
    return (
      <div className='filter-panel ui-side-filter'>
        {this.renderJsSwitch()}
      </div>
    )
  }
}

module.exports = BoxSidebar
