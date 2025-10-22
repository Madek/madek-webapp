import React from 'react'
import { isEmpty, getPath } from '../../lib/utils.js'
import t from '../../lib/i18n-translate.js'
import PageHeader from '../ui-components/PageHeader.js'
import PageContent from './PageContent.jsx'
import MediaResourcesBox from '../decorators/MediaResourcesBox.jsx'
import { format as formatUrl } from 'url'
import { decorateExternalURI } from '../../lib/URIAuthorityControl'

const decoExternalUris = uris => {
  const sortedUris = uris.slice().sort((a, b) => {
    const aKind = getPath(a, 'authority_control.kind') || ''
    const bKind = getPath(b, 'authority_control.kind') || ''
    return aKind.localeCompare(bKind)
  })

  return (
    <ul className="list-unstyled">
      {sortedUris.map((uri, i) => {
        let label = uri.uri
        let badge = false
        if (getPath(uri, 'authority_control.kind')) {
          label = uri.authority_control.label
          const providerLabel = uri.authority_control.provider.label
          badge = (
            <span className="ui-authority-control-badge">
              <abbr title={uri.authority_control.provider.name}>{providerLabel}</abbr>:{' '}
            </span>
          )
        }
        const content = !uri.is_web ? (
          <span>{label}</span>
        ) : (
          <a href={uri.uri} target="_blank" rel="noreferrer noopener">
            {label}
          </a>
        )
        return (
          <li key={i} data-authority-control={JSON.stringify(uri.authority_control)}>
            {badge}
            {content}
          </li>
        )
      })}
    </ul>
  )
}

const infotable = p => {
  const autority_links = p.external_uris.filter(uri => getPath(uri, 'authority_control.kind'))
  const external_links = p.external_uris.filter(uri => !getPath(uri, 'authority_control.kind'))

  const nameFields = [[t('person_show_only_name'), p.label]]

  return []
    .concat(nameFields)
    .concat([
      external_links.length === 0
        ? null
        : [t('person_show_external_uris'), decoExternalUris(external_links)],
      autority_links.length === 0
        ? null
        : [t('person_show_external_uris_autority_control'), decoExternalUris(autority_links)],
      [t('person_show_description'), p.description]
    ])
    .filter(Boolean)
}

const PersonShow = ({ get, for_url, authToken }) => {
  const title = get.to_s
  const { resources } = get
  get.external_uris = get.external_uris.map(uri => decorateExternalURI(uri))

  const actions = get.actions.edit.url ? (
    <a href={get.actions.edit.url} className="primary-button">
      {t('person_show_edit_btn')}
    </a>
  ) : undefined

  return (
    <PageContent>
      <PageHeader title={title} icon="tag" actions={actions} />
      <div className="ui-container tab-content bordered bright rounded-right rounded-bottom">
        <div className="ui-container pal">
          <table className="borderless">
            <tbody>
              {infotable(get).map(([label, value], i) => {
                if (isEmpty(value)) {
                  return null
                }
                return (
                  <tr key={label + i}>
                    <td className="ui-summary-label">{label}</td>
                    <td className="ui-summary-content measure-double">{value}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
        <MediaResourcesBox
          for_url={formatUrl(for_url)}
          get={resources}
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

export default PersonShow
module.exports = PersonShow
module.exports.deco_external_uris = decoExternalUris
