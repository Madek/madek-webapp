React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../../lib/string-translation.js')('de')
Icon = require('../../ui-components/Icon.cjsx')
PageContent = require('../PageContent.cjsx')
PageHeader = require('../../ui-components/PageHeader.js')
Tabs = require('../Tabs.cjsx')
Tab = require('../Tab.cjsx')
TabContent = require('../TabContent.cjsx')
parseUrl = require('url').parse
VocabularyPage = require('./VocabularyPage.cjsx')

MIN_COLS = 2 # for layout
MAX_COLS = 4

MetakeyItem = ({meta_key, keywords}) =>
  <div className='ui-metadata-box prl mbm'>
    <h3 className='title-s-alt separated light mbx'>
      {meta_key.label}
      <small className='title-xs-alt mlx'>(a-z)</small>
    </h3>
    <ul className='ui-tag-cloud small ellipsed compact'>
      {f.map keywords, (kw) ->
        <KeywordItem {...kw} key={kw.uuid}/>
      }
    </ul>
  </div>

KeywordItem = ({uuid, label, url}) ->
  <li className='ui-tag-cloud-item'>
    <a className='ui-tag-button' title={label} href={url}>
      {label}
    </a>
  </li>

module.exports = React.createClass
  displayName: 'VocabularyKeywords'

  render: ({get, app} = @props) ->
    metaKeys = get.meta_keys_with_keywords
    numCols = Math.max(MIN_COLS, Math.min(MAX_COLS, metaKeys.length))
    metaKeyColumns = f.chunk(metaKeys, numCols)
    hint = t('vocabularies_keywords_hint_1') + get.page.vocabulary.label + t('vocabularies_keywords_hint_2')

    <VocabularyPage page={get.page} for_url={app.url}>
      <div className='bright ui-container pal rounded'>
        <h2 className='title-m mbl'>{hint}</h2>
        <div className='mbl'>
          {f.map(metaKeyColumns, (metaKeys, i) ->
            <div className={"col1of#{numCols}"} key={i}>
              {f.map metaKeys, (mk) ->
                <MetakeyItem {...mk} key={mk.meta_key.uuid} />
              }
            </div>
          )}
        </div>
      </div>
    </VocabularyPage>
