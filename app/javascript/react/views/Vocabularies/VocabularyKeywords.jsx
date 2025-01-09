/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('lodash')
const t = require('../../../lib/i18n-translate.js')
const Icon = require('../../ui-components/Icon.jsx')
const PageContent = require('../PageContent.jsx')
const PageHeader = require('../../ui-components/PageHeader.js')
const Tabs = require('../Tabs.jsx')
const Tab = require('../Tab.jsx')
const TabContent = require('../TabContent.jsx')
const parseUrl = require('url').parse
const VocabularyPage = require('./VocabularyPage.jsx')

const MIN_COLS = 2 // for layout
const MAX_COLS = 4

const MetakeyItem = function({ meta_key, keywords }) {
  const [sortLabel, sortTitle] = Array.from(
    meta_key.alphabetical_order
      ? [t('meta_key_order_alphabetical'), t('meta_key_order_alphabetical_hint')]
      : [t('meta_key_order_custom'), t('meta_key_order_custom_hint')]
  )

  return (
    <div className="ui-metadata-box prl mbm">
      <h3 className="title-s-alt separated light mbx">
        {meta_key.label}
        <small title={sortTitle} className="title-xs-alt mlx">
          ({sortLabel})
        </small>
      </h3>
      {f.size(keywords) > 0 ? (
        <ul className="ui-tag-cloud small ellipsed compact">
          {f.map(keywords, kw => (
            <KeywordItem {...Object.assign({}, kw, { key: kw.uuid })} />
          ))}
        </ul>
      ) : (
        <div>{t('vocabularies_no_keywords')}</div>
      )}
    </div>
  )
}

var KeywordItem = ({ uuid, label, url }) => (
  <li className="ui-tag-cloud-item">
    <a className="ui-tag-button" title={label} href={url}>
      {label}
    </a>
  </li>
)

module.exports = React.createClass({
  displayName: 'VocabularyKeywords',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    const metaKeys = get.meta_keys_with_keywords
    const numCols = Math.max(MIN_COLS, Math.min(MAX_COLS, metaKeys.length))
    const metaKeyColumns = f.chunk(metaKeys, numCols)
    const hint =
      t('vocabularies_keywords_hint_1') +
      '"' +
      get.page.vocabulary.label +
      '"' +
      t('vocabularies_keywords_hint_2')

    return (
      <VocabularyPage page={get.page} for_url={this.props.for_url}>
        <div className="ui-container pal">
          <h2 className="title-m mbl">{hint}</h2>
          <div className="mbl">
            {f.map(metaKeyColumns, (metaKeys, i) => (
              <div className={`col1of${numCols}`} key={i}>
                {f.map(metaKeys, mk => (
                  <MetakeyItem {...Object.assign({}, mk, { key: mk.meta_key.uuid })} />
                ))}
              </div>
            ))}
          </div>
        </div>
      </VocabularyPage>
    )
  }
})
