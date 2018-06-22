React = require('react')
isEmpty = require('lodash/isEmpty')
ui = require('../../lib/ui.coffee')
t = require('../../../lib/i18n-translate.js')
PageHeader = require('../../ui-components/PageHeader.js')
PageContent = require('../PageContent.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')
f = require('lodash')
resourceTypeSwitcher = require('../../lib/resource-type-switcher.cjsx')


link = (c, h) -> <a href={h}>{c}</a>

infotable = (v, mk, kw, contentsPath) ->
  [
    [
      t('vocabulary_term_info_term'),
      link(kw.label, kw.url)
    ],
    [
      t('vocabulary_term_info_description'),
      kw.description
    ],
    [
      t('vocabulary_term_info_url'),
      if !kw.external_uri then false else link(kw.external_uri, kw.external_uri)
    ],
    [
      t('sitemap_metakey'),
      link(
        <span>{mk.label} <small>({mk.uuid})</small></span>,
        mk.url
      )
    ],
    [
      t('vocabulary_term_info_rdfclass'),
      kw.rdf_class
    ],
    [
      t('sitemap_vocabulary'),
      link(v.label, v.url)
    ]
  ]

VocabulariesShow = React.createClass
  displayName: 'VocabularyTerm',

  forUrl: () ->
    libUrl.format(@props.get.keyword.resources.config.for_url)

  render: () ->

    get = @props.get

    { vocabulary, meta_key, keyword, contents_path } = get

    title = '"' + keyword.label + '"'

    renderSwitcher = (boxUrl) =>
      resourceTypeSwitcher(get.keyword.resources, boxUrl, false, null)

    <PageContent>
      <PageHeader title={title} icon='tag' />
      <div className='ui-container tab-content bordered bright rounded-right rounded-bottom'>
        <div className='ui-container pal'>
          <table className='borderless'>
            <tbody>
              {
                f.map(
                  infotable(vocabulary, meta_key, keyword, contents_path),
                  ([label, value], i) ->
                    if isEmpty(value)
                      null
                    else
                      <tr key={label + i}>
                        <td className='ui-summary-label'>{label}</td>
                        <td className='ui-summary-content'>{value}</td>
                      </tr>
                )
              }
            </tbody>
          </table>
        </div>
        <MediaResourcesBox
          for_url={@props.for_url}
          get={get.keyword.resources} authToken={@props.authToken}
          mods={[ {bordered: false}, 'rounded-bottom' ]}
          renderSwitcher={renderSwitcher}
          enableOrdering={true}
          enableOrderByTitle={true} />
      </div>
    </PageContent>


module.exports = VocabulariesShow
