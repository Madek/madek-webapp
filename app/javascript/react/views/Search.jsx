import React from 'react'
import t from '../../lib/i18n-translate.js'
import { parse as parseUrl } from 'url'
import PageContent from './PageContent.jsx'
import PageHeader from '../ui-components/PageHeader.jsx'

const Search = ({ submit_url }) => {
  const parsedQuery = parseUrl(submit_url, true).query
  const hasLang = parsedQuery && parsedQuery.lang

  return (
    <PageContent>
      <PageHeader icon="lens" title={t('sitemap_search')} actions={null} />
      <div className="bordered ui-container midtone rounded-right rounded-bottom table">
        <div className="ui-search-form">
          <form action={submit_url} acceptCharset="UTF-8" method="get">
            <input name="utf8" type="hidden" value="✓" />
            {hasLang && <input type="hidden" name="lang" value={parsedQuery.lang} />}
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

export default Search
module.exports = Search
