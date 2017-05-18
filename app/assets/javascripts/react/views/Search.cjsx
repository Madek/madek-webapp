React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../lib/string-translation.js')('de')

PageContent = require('./PageContent.cjsx')
PageHeader = require('../ui-components/PageHeader.js')

module.exports = React.createClass
  displayName: 'Search'

  render: ({get, authToken, for_url} = @props) ->
    <PageContent>
      <PageHeader icon='lens' title={t('sitemap_search')} actions={null} />
      <div className='bordered ui-container midtone rounded-right rounded-bottom table'>
        <div className='ui-search-form'>
          <form action='/search/result' accept-charset='UTF-8' method='get'>
            <input name='utf8' type='hidden' value='✓' />
            <div className='ui-search large mts'>
              <input type='text' name='search' id='search' autofocus='autofocus' className='block ui-search-input' />
              <button name='button' type='submit' className='primary-button ui-search-button'>
                {t('search_btn_search')}
              </button>
              <div>
                <input type='radio' name='search_type' value='fulltext' defaultChecked={true} />
                {' Volltext '}
                <input type='radio' name='search_type' value='filename' defaultChecked={false} />
                {' Filename'}
              </div>
            </div>
          </form>
        </div>
      </div>
    </PageContent>
