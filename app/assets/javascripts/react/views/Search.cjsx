React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../lib/i18n-translate.js')
parseUrl = require('url').parse

PageContent = require('./PageContent.cjsx')
PageHeader = require('../ui-components/PageHeader.js')

module.exports = React.createClass
  displayName: 'Search'

  parsedQuery: () ->
    parsedQuery = parseUrl(@props.submit_url, true).query
    if f.has(parsedQuery, 'lang')
      parsedQuery
    else
      false

  render: ({get, authToken, for_url, submit_url} = @props) ->
    parsedQuery = @parsedQuery()

    <PageContent>
      <PageHeader icon='lens' title={t('sitemap_search')} actions={null} />
      <div className='bordered ui-container midtone rounded-right rounded-bottom table'>
        <div className='ui-search-form'>
          <form action={submit_url} accept-charset='UTF-8' method='get'>
            <input name='utf8' type='hidden' value='✓' />
            {if parsedQuery
              <input type='hidden' name='lang' value={parsedQuery['lang']} />}
            <div className='ui-search large mts'>
              <input type='text' name='search' id='search' autofocus='autofocus' className='block ui-search-input' />
              <button name='button' type='submit' className='primary-button ui-search-button'>
                {t('search_btn_search')}
              </button>
              <div>
                <input type='radio' name='search_type' value='fulltext' defaultChecked={true} />
                {' ' + t('search_full_text') + ' '}
                <input type='radio' name='search_type' value='filename' defaultChecked={false} />
                {' ' + t('search_filename')}
              </div>
            </div>
          </form>
        </div>
      </div>
    </PageContent>
