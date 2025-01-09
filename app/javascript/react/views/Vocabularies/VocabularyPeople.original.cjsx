React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../../lib/i18n-translate.js')
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

MetakeyItem = ({meta_key, keywords}) ->
  [sortLabel, sortTitle] =
    [t('meta_key_order_alphabetical'), t('meta_key_order_alphabetical_hint')]

  <div className='ui-metadata-box prl mbm'>
    <h3 className='title-s-alt separated light mbx'>
      {meta_key.label}
      <small title={sortTitle} className='title-xs-alt mlx'>({sortLabel})</small>
    </h3>

    {
      if f.size(keywords) > 0
        <ul className='ui-tag-cloud small ellipsed compact'>
          {f.map keywords, (kw) ->
            <KeywordItem {...kw} key={kw.uuid}/>
          }
        </ul>
      else
        <div>
          {t('vocabularies_no_people')}
        </div>

    }

  </div>

KeywordItem = ({uuid, label, url}) ->
  <li className='ui-tag-cloud-item'>
    <a className='ui-tag-button' title={label} href={url}>
      {label}
    </a>
  </li>

module.exports = React.createClass
  displayName: 'VocabularyPeople'

  render: ({get} = @props) ->
    metaKeys = get.meta_keys_with_people
    numCols = Math.max(MIN_COLS, Math.min(MAX_COLS, metaKeys.length))
    metaKeyColumns = f.chunk(metaKeys, numCols)
    hint = t('vocabularies_people_hint_1') + '"' + get.page.vocabulary.label + '"' + t('vocabularies_people_hint_2')

    <VocabularyPage page={get.page} for_url={@props.for_url}>
      <div className='ui-container pal'>
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
