React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../../lib/string-translation.js')('de')
Icon = require('../../ui-components/Icon.cjsx')
PageContent = require('../PageContent.cjsx')
PageHeader = require('../../ui-components/PageHeader.js')
ResourceKeyword = require('../../decorators/ResourceKeyword.cjsx')
Tabs = require('../Tabs.cjsx')
Tab = require('../Tab.cjsx')
TabContent = require('../TabContent.cjsx')
parseUrl = require('url').parse
VocabularyPage = require('./VocabularyPage.cjsx')

metaKeysPerColumn = (meta_keys, col_count, col) ->
  f.filter meta_keys, (meta_key, index) ->
    index % col_count == col

metaKeyColumns = (meta_keys, col_count) ->
  f.range(col_count).map (col) ->
    metaKeysPerColumn(meta_keys, col_count, col)

module.exports = React.createClass
  displayName: 'VocabularyKeywords'

  _renderKeyword: (keyword) ->
    <ResourceKeyword key={'keyword_' + keyword.uuid} keyword={keyword} hideIcon={true} />

  _renderMetakey: (meta_key) ->
    <div className='ui-metadata-box prl mbm' key={'meta_key_' + meta_key.meta_key.uuid}>
      <h3 className='title-s-alt separated light mbx'>
        {meta_key.meta_key.label}
        <small className='title-xs-alt mlx'>(a-z)</small>
      </h3>
      <ul className='ui-tag-cloud small ellipsed compact' key={meta_key.meta_key.uuid}>
        {
          f.map meta_key.keywords, (keyword) =>
            @_renderKeyword(keyword)
        }
      </ul>
    </div>

  _renderColumn: (col, meta_keys) ->
    <div className='col1of4' key={'col_' + col}>
      {
        f.map meta_keys, (meta_key) =>
          @_renderMetakey(meta_key)
      }
    </div>


  render: ({get} = @props) ->

    col_count = 4

    hint = t('vocabularies_keywords_hint_1') + get.page.vocabulary.label + t('vocabularies_keywords_hint_2')

    <VocabularyPage page={get.page} for_url={@props.for_url}>
      <div className='bright ui-container pal rounded'>
        <h2 className='title-m mbl'>{hint}</h2>
        <div className='mbl'>
          {
            f.map metaKeyColumns(get.meta_keys_with_keywords, col_count), (col_meta_keys, col) =>
              @_renderColumn(col, col_meta_keys)
          }
        </div>
      </div>
    </VocabularyPage>
