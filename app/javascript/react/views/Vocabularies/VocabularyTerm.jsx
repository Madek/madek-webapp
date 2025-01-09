/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const isEmpty = require('lodash/isEmpty')
const ui = require('../../lib/ui.js')
const t = require('../../../lib/i18n-translate.js')
const PageHeader = require('../../ui-components/PageHeader.js')
const PageContent = require('../PageContent.cjsx')
const MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
const libUrl = require('url')
const f = require('lodash')

const link = (c, h) => <a href={h}>{c}</a>

const infotable = (v, mk, kw, contentsPath) =>
  f.compact([
    [t('vocabulary_term_info_term'), link(kw.label, kw.url)],
    [t('vocabulary_term_info_description'), kw.description],
    kw.external_uris && kw.external_uris.length > 0
      ? [
          kw.external_uris.length > 1
            ? t('vocabulary_term_info_urls')
            : t('vocabulary_term_info_url'),
          deco_external_uris(kw.external_uris)
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
  ])

const VocabulariesShow = React.createClass({
  displayName: 'VocabularyTerm',

  forUrl() {
    return libUrl.format(this.props.get.keyword.resources.config.for_url)
  },

  render() {
    const { get } = this.props

    const { vocabulary, meta_key, keyword, contents_path } = get

    const title = `"${keyword.label}"`

    return (
      <PageContent>
        <PageHeader title={title} icon="tag" />
        <div className="ui-container tab-content bordered bright rounded-right rounded-bottom">
          <div className="ui-container pal">
            <table className="borderless">
              <tbody>
                {f.map(infotable(vocabulary, meta_key, keyword, contents_path), function(...args) {
                  const [label, value] = Array.from(args[0]),
                    i = args[1]
                  if (isEmpty(value)) {
                    return null
                  } else {
                    return (
                      <tr key={label + i}>
                        <td className="ui-summary-label">{label}</td>
                        <td className="ui-summary-content">{value}</td>
                      </tr>
                    )
                  }
                })}
              </tbody>
            </table>
          </div>
          <MediaResourcesBox
            for_url={this.props.for_url}
            get={get.keyword.resources}
            authToken={this.props.authToken}
            mods={[{ bordered: false }, 'rounded-bottom']}
            resourceTypeSwitcherConfig={{ showAll: false }}
            enableOrdering={true}
            enableOrderByTitle={true}
          />
        </div>
      </PageContent>
    )
  }
})

var deco_external_uris = uris => (
  <ul className="list-unstyled">
    {uris.map(uri => (
      <li>
        <a href={uri} target="_blank" rel="noreferrer noopener">
          {uri}
        </a>
      </li>
    ))}
  </ul>
)

module.exports = VocabulariesShow
