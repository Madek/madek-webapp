/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'lodash'
import t from '../../lib/i18n-translate.js'
import { parse as parseUrl } from 'url'
import PageContent from './PageContent.jsx'
import PageHeader from '../ui-components/PageHeader.js'

module.exports = createReactClass({
  displayName: 'Search',

  parsedQuery() {
    const parsedQuery = parseUrl(this.props.submit_url, true).query
    if (f.has(parsedQuery, 'lang')) {
      return parsedQuery
    } else {
      return false
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { submit_url } = param
    const parsedQuery = this.parsedQuery()

    return (
      <PageContent>
        <PageHeader icon="lens" title={t('sitemap_search')} actions={null} />
        <div className="bordered ui-container midtone rounded-right rounded-bottom table">
          <div className="ui-search-form">
            <form action={submit_url} acceptCharset="UTF-8" method="get">
              <input name="utf8" type="hidden" value="✓" />
              {parsedQuery ? (
                <input type="hidden" name="lang" value={parsedQuery['lang']} />
              ) : undefined}
              <div className="ui-search large mts">
                <input
                  type="text"
                  name="search"
                  id="search"
                  autoFocus="autofocus"
                  className="block ui-search-input"
                />
                <button name="button" type="submit" className="primary-button ui-search-button">
                  {t('search_btn_search')}
                </button>
                <div>
                  <input type="radio" name="search_type" value="fulltext" defaultChecked={true} />
                  {` ${t('search_full_text')} `}
                  <input type="radio" name="search_type" value="filename" defaultChecked={false} />
                  {` ${t('search_filename')}`}
                </div>
              </div>
            </form>
          </div>
        </div>
      </PageContent>
    )
  }
})
