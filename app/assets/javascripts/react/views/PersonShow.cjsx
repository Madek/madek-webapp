React = require('react')
isEmpty = require('lodash/isEmpty')
t = require('../../lib/i18n-translate.js')
PageHeader = require('../ui-components/PageHeader.js')
PageContent = require('./PageContent.cjsx')
MediaResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')
f = require('lodash')
resourceTypeSwitcher = require('../lib/resource-type-switcher.cjsx')

infotable = (p) ->
  [
    [
      t('person_show_first_name'),
      p.first_name
    ],
    [
      t('person_show_last_name'),
      p.last_name
    ],
    [
      t('person_show_external_uri'),
      if !p.external_uri then false else <a href={p.external_uri}>{p.external_uri}</a>
    ],
    [
      t('person_show_description'),
      p.description
    ]
  ]


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

module.exports = PersonShow
