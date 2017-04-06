import React from 'react'
import isEmpty from 'lodash/isEmpty'
import ui from '../../lib/ui.coffee'
const t = ui.t('de')
import PageHeader from '../../ui-components/PageHeader.js'
import PageContent from '../PageContent.cjsx'

const link = (c, h) => <a href={h}>{c}</a>

const infotable = (v, mk, kw, contentsPath) => [
  [ t('vocabulary_term_info_rdfclass'), kw.rdf_class ],
  [ t('vocabulary_term_info_description'), kw.description ],
  [
    t('vocabulary_term_info_url'),
    !kw.external_uri ? '' : link(kw.external_uri, kw.external_uri)
  ],
  [ t('vocabulary_term_info_contents'), link(kw.usage_count, contentsPath) ],
  [
    t('sitemap_metakey'),
    link(<span>{mk.label} <small>({mk.uuid})</small></span>, mk.url)
  ],
  [ t('vocabulary_term_info_term'), link(kw.label, kw.url) ],
  [ t('sitemap_vocabulary'), link(v.label, v.url) ]
]

const VocabulariesShow = React.createClass({
  displayName: 'VocabularyShow',
  render (get = this.props.get) {
    const { vocabulary, meta_key, keyword, contents_path } = get

    const title = `"${keyword.label}"`

    return (
      <PageContent>
        <PageHeader title={title} icon='tag' />
        <div
          className='ui-container bright pal mbh rounded-top-right bordered rounded-right rounded-bottom'
        >
          <table className='borderless'>
            <tbody>
              {infotable(vocabulary, meta_key, keyword, contents_path).map(
                  ([ label, value ]) =>
                    isEmpty(value) ? null : <tr key={label + value}>
                      <td className='ui-summary-label'>{label}</td>
                      <td className='ui-summary-content'>{value}</td>
                    </tr>
                )}
            </tbody>
          </table>
        </div>
      </PageContent>
    )
  }
})

module.exports = VocabulariesShow
