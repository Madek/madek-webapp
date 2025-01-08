/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const classList = require('classnames')

const t = require('../../../lib/i18n-translate.js')
const setUrlParams = require('../../../lib/set-params-for-url.js')
const UI = require('../../ui-components/index.js')
const MediaResourcesLine = require('./MediaResourcesLine.jsx').default

module.exports = React.createClass({
  displayName: 'Views.MediaEntry.BrowseEntriesList',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { browse, isLoading, header, authToken } = param
    const loadingError = t('browse_entries_loading_error')
    // fallback view
    if (isLoading || !browse) {
      let left
      return (
        <div>
          {header}
          {(left = !isLoading && !browse) != null
            ? left
            : { loadingError: <UI.Preloader mods="mal" /> }}
        </div>
      )
    }

    // main view
    const keyword_clusters = f.map(browse.entry_ids_by_shared_keywords, function({
      keyword_ids,
      entry_ids
    }) {
      const keywords = keyword_ids.map(function(id) {
        const kw = browse.keywords_by_id[id]
        const mk = browse.meta_keys_by_id[kw.meta_key_id]
        const voc = browse.vocabularies_by_id[mk.vocabulary_id]
        return f.assign({}, kw, { metaKey: f.assign({}, mk, { vocabulary: voc }) })
      })
      const keywordsGrouped = f.values(f.groupBy(keywords, 'meta_key_id'))
      const keywordsSorted = f.sortBy(
        f.sortBy(keywordsGrouped, '0.metaKey.position'),
        '0.metaKey.vocabulary.position'
      )

      return {
        entries: entry_ids.map(id => browse.entries_by_id[id]),
        keywordsByMetaKey: keywordsSorted
      }
    })

    return (
      <div data-ui-entry-browse-list={true}>
        {header}
        {f.isEmpty(keyword_clusters) ? (
          <div className="by-center">{t('no_content_fallback')}</div>
        ) : (
          <div>
            {f.map(keyword_clusters, ({ keywordsByMetaKey, entries }) => (
              <MediaResourcesLine
                resources={entries}
                authToken={authToken}
                key={f.get(entries, '0.uuid')}>
                {f.map(keywordsByMetaKey, function(keywords, index, list) {
                  const metaKey = f.get(keywords, '0.metaKey')
                  const isLast = index === list.length - 1

                  return (
                    <span key={f.map(keywords, 'uuid').join('')}>
                      <span className="title-xs">{metaKey.label} </span>
                      <ul className="ui-tag-cloud-small" style={{ display: 'inline' }}>
                        {f.map(keywords, kw => (
                          <KeywordItem {...Object.assign({}, kw, { key: kw.uuid })} />
                        ))}
                      </ul>
                    </span>
                  )
                })}
                <a
                  className="strong"
                  href={entriesFilterPath(browse.filter_search_path, f.flatten(keywordsByMetaKey))}>
                  {t('browse_entries_filter_link')}
                </a>
              </MediaResourcesLine>
            ))}
          </div>
        )}
      </div>
    )
  }
})

var entriesFilterPath = (path, keywords) =>
  setUrlParams(path, {
    list: {
      show_filter: true,
      filter: JSON.stringify({
        meta_data: f.map(keywords, kw => ({ value: kw.uuid, key: kw.meta_key_id }))
      })
    }
  })

var KeywordItem = ({ uuid, label, url }) => (
  <li className="ui-tag-cloud-item">
    <a className="ui-tag-button" title={label} href={url}>
      {label}
    </a>
  </li>
)
