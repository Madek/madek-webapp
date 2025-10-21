import React from 'react'
import { isEmpty } from '../../../lib/utils.js'
import t from '../../../lib/i18n-translate.js'
import PageHeader from '../../ui-components/PageHeader.js'
import PageContent from '../PageContent.jsx'
import MediaResourcesBox from '../../decorators/MediaResourcesBox.jsx'

const link = (c, h) => <a href={h}>{c}</a>

const decoExternalUris = uris => (
  <ul className="list-unstyled">
    {uris.map((uri, i) => (
      <li key={i}>
        <a href={uri} target="_blank" rel="noreferrer noopener">
          {uri}
        </a>
      </li>
    ))}
  </ul>
)

const infotable = (v, mk, kw) =>
  [
    [t('vocabulary_term_info_term'), link(kw.label, kw.url)],
    [t('vocabulary_term_info_description'), kw.description],
    kw.external_uris && kw.external_uris.length > 0
      ? [
          kw.external_uris.length > 1
            ? t('vocabulary_term_info_urls')
            : t('vocabulary_term_info_url'),
          decoExternalUris(kw.external_uris)
        ]
      : undefined,
    [
      t('sitemap_metakey'),
      link(
        <span>
          {mk.label} <small>({mk.uuid})</small>
        </span>,
        mk.url
      )
    ],
    [t('vocabulary_term_info_rdfclass'), kw.rdf_class],
    [t('sitemap_vocabulary'), link(v.label, v.url)]
  ].filter(Boolean)

const VocabularyTerm = ({ get, for_url, authToken }) => {
  const { vocabulary, meta_key, keyword } = get
  const title = `"${keyword.label}"`

  return (
    <PageContent>
      <PageHeader title={title} icon="tag" />
      <div className="ui-container tab-content bordered bright rounded-right rounded-bottom">
        <div className="ui-container pal">
          <table className="borderless">
            <tbody>
              {infotable(vocabulary, meta_key, keyword).map(([label, value], i) => {
                if (isEmpty(value)) {
                  return null
                }
                return (
                  <tr key={label + i}>
                    <td className="ui-summary-label">{label}</td>
                    <td className="ui-summary-content">{value}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
        <MediaResourcesBox
          for_url={for_url}
          get={get.keyword.resources}
          authToken={authToken}
          mods={[{ bordered: false }, 'rounded-bottom']}
          resourceTypeSwitcherConfig={{ showAll: false }}
          enableOrdering={true}
          enableOrderByTitle={true}
        />
      </div>
    </PageContent>
  )
}

export default VocabularyTerm
module.exports = VocabularyTerm
