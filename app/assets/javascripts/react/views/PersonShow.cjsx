React = require('react')
isEmpty = require('lodash/isEmpty')
t = require('../../lib/i18n-translate.js')
PageHeader = require('../ui-components/PageHeader.js')
PageContent = require('./PageContent.cjsx')
MediaResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')
f = require('active-lodash')
resourceTypeSwitcher = require('../lib/resource-type-switcher.cjsx')

infotable = (p) ->
  autority_links = f.filter(p.external_uris, 'authority_control.kind')
  external_links = f.difference(p.external_uris, autority_links)

  f.compact([
    [
      t('person_show_first_name'),
      p.first_name
    ],
    [
      t('person_show_last_name'),
      p.last_name
    ],
    if f.isEmpty(external_links) then null else [
      t('person_show_external_uris'),
      deco_external_uris(external_links)
    ],
    if f.isEmpty(autority_links) then null else [
      t('person_show_external_uris_autority_control'),
      deco_external_uris(autority_links)
    ],
    [
      t('person_show_description'),
      p.description
    ]
  ])


PersonShow = React.createClass
  displayName: 'PersonShow',

  forUrl: () ->
    libUrl.format(@props.for_url)

  render: ->
    get = @props.get
    title = get.to_s
    { resources } = get

    renderSwitcher = (boxUrl) =>
      resourceTypeSwitcher(resources, boxUrl, false, null)

    <PageContent>
      <PageHeader title={title} icon='tag' />
      <div className='ui-container tab-content bordered bright rounded-right rounded-bottom'>
        <div className='ui-container pal'>
          <table className='borderless'>
            <tbody>
              {
                f.map(
                  infotable(get),
                  ([label, value], i) ->
                    if isEmpty(value)
                      null
                    else
                      <tr key={label + i}>
                        <td className='ui-summary-label'>{label}</td>
                        <td className='ui-summary-content measure-double'>{value}</td>
                      </tr>
                )
              }
            </tbody>
          </table>
        </div>
        <MediaResourcesBox
          for_url={@forUrl()}
          get={resources} authToken={@props.authToken}
          mods={[ {bordered: false}, 'rounded-bottom' ]}
          renderSwitcher={renderSwitcher}
          enableOrdering={true}
          enableOrderByTitle={true} />
      </div>
    </PageContent>

deco_external_uris = (uris) ->
  uris = f.sortBy(uris, 'authority_control.kind')
  <ul className='list-unstyled'>{uris.map((uri, i) ->
    label = uri.uri
    badge = false
    if f.get(uri, 'authority_control.kind')
      label = uri.authority_control.label
      providerLabel = uri.authority_control.provider.label
      badge = <span className='ui-authority-control-badge' >
        <abbr title={uri.authority_control.provider.name}>{providerLabel}</abbr>: </span>
    content = if !uri.is_web
      <span>{label}</span>
    else
      <a href={uri.uri} target="_blank" rel="noreferrer noopener">{label}</a>
    return <li key={i}>{badge}{content}</li>
  )}</ul>

module.exports = PersonShow
