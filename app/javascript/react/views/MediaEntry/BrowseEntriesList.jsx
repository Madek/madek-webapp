import React from 'react'
import { isEmpty, getPath } from '../../../lib/utils.js'
import t from '../../../lib/i18n-translate.js'
import setUrlParams from '../../../lib/set-params-for-url.js'
import UI from '../../ui-components/index.js'
import MediaResourcesLine from './MediaResourcesLine.jsx'

const entriesFilterPath = (path, keywords) =>
  setUrlParams(path, {
    list: {
      show_filter: true,
      filter: JSON.stringify({
        meta_data: keywords.map(kw => ({ value: kw.uuid, key: kw.meta_key_id }))
      })
    }
  })

const KeywordItem = ({ label, url }) => (
  <li className="ui-tag-cloud-item">
    <a className="ui-tag-button" title={label} href={url}>
      {label}
    </a>
  </li>
)

const BrowseEntriesList = ({ browse, isLoading, header, authToken }) => {
  // fallback view
  if (isLoading || !browse) {
    return (
      <div>
        {header}
        {!isLoading && !browse ? { loadingError: <UI.Preloader mods="mal" /> } : null}
      </div>
    )
  }

  // main view
  const keyword_clusters = browse.entry_ids_by_shared_keywords.map(({ keyword_ids, entry_ids }) => {
    const keywords = keyword_ids.map(id => {
      const kw = browse.keywords_by_id[id]
      const mk = browse.meta_keys_by_id[kw.meta_key_id]
      const voc = browse.vocabularies_by_id[mk.vocabulary_id]
      return { ...kw, metaKey: { ...mk, vocabulary: voc } }
    })

    // Group by meta_key_id
    const keywordsGrouped = Object.values(
      keywords.reduce((acc, kw) => {
        if (!acc[kw.meta_key_id]) acc[kw.meta_key_id] = []
        acc[kw.meta_key_id].push(kw)
        return acc
      }, {})
    )

    // Sort by position
    const keywordsSorted = keywordsGrouped
      .slice()
      .sort((a, b) => {
        const posA = getPath(a, '0.metaKey.position') || 0
        const posB = getPath(b, '0.metaKey.position') || 0
        return posA - posB
      })
      .sort((a, b) => {
        const vocPosA = getPath(a, '0.metaKey.vocabulary.position') || 0
        const vocPosB = getPath(b, '0.metaKey.vocabulary.position') || 0
        return vocPosA - vocPosB
      })

    return {
      entries: entry_ids.map(id => browse.entries_by_id[id]),
      keywordsByMetaKey: keywordsSorted
    }
  })

  return (
    <div data-ui-entry-browse-list={true}>
      {header}
      {isEmpty(keyword_clusters) ? (
        <div className="by-center">{t('no_content_fallback')}</div>
      ) : (
        <div>
          {keyword_clusters.map(({ keywordsByMetaKey, entries }) => (
            <MediaResourcesLine
              resources={entries}
              authToken={authToken}
              key={getPath(entries, '0.uuid')}>
              {keywordsByMetaKey.map(keywords => {
                const metaKey = getPath(keywords, '0.metaKey')

                return (
                  <span key={keywords.map(kw => kw.uuid).join('')}>
                    <span className="title-xs">{metaKey.label} </span>
                    <ul className="ui-tag-cloud-small" style={{ display: 'inline' }}>
                      {keywords.map(kw => (
                        <KeywordItem key={kw.uuid} {...kw} />
                      ))}
                    </ul>
                  </span>
                )
              })}
              <a
                className="strong"
                href={entriesFilterPath(browse.filter_search_path, keywordsByMetaKey.flat())}>
                {t('browse_entries_filter_link')}
              </a>
            </MediaResourcesLine>
          ))}
        </div>
      )}
    </div>
  )
}

export default BrowseEntriesList
module.exports = BrowseEntriesList
