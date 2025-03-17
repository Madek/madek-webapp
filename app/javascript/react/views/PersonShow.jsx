/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import isEmpty from 'lodash/isEmpty'
import t from '../../lib/i18n-translate.js'
import PageHeader from '../ui-components/PageHeader.js'
import PageContent from './PageContent.jsx'
import MediaResourcesBox from '../decorators/MediaResourcesBox.jsx'
import libUrl from 'url'
import f from 'active-lodash'
import { decorateExternalURI } from '../../lib/URIAuthorityControl'

const infotable = function (p) {
  const autority_links = f.filter(p.external_uris, 'authority_control.kind')
  const external_links = f.difference(p.external_uris, autority_links)

  const nameFields = [[t('person_show_only_name'), p.label]]

  return f.compact(
    []
      .concat(nameFields)
      .concat([
        f.isEmpty(external_links)
          ? null
          : [t('person_show_external_uris'), deco_external_uris(external_links)],
        f.isEmpty(autority_links)
          ? null
          : [t('person_show_external_uris_autority_control'), deco_external_uris(autority_links)],
        [t('person_show_description'), p.description]
      ])
  )
}

const PersonShow = createReactClass({
  displayName: 'PersonShow',

  forUrl() {
    return libUrl.format(this.props.for_url)
  },

  render() {
    const { get } = this.props
    const title = get.to_s
    const { resources } = get
    get.external_uris = f.map(get.external_uris, uri => decorateExternalURI(uri))

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
                {f.map(infotable(get), function (...args) {
                  const [label, value] = Array.from(args[0]),
                    i = args[1]
                  if (isEmpty(value)) {
                    return null
                  } else {
                    return (
                      <tr key={label + i}>
                        <td className="ui-summary-label">{label}</td>
                        <td className="ui-summary-content measure-double">{value}</td>
                      </tr>
                    )
                  }
                })}
              </tbody>
            </table>
          </div>
          <MediaResourcesBox
            for_url={this.forUrl()}
            get={resources}
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

var deco_external_uris = function (uris) {
  uris = f.sortBy(uris, 'authority_control.kind')
  return (
    <ul className="list-unstyled">
      {uris.map(function (uri, i) {
        let label = uri.uri
        let badge = false
        if (f.get(uri, 'authority_control.kind')) {
          ;({ label } = uri.authority_control)
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

module.exports = PersonShow
module.exports.deco_external_uris = deco_external_uris
