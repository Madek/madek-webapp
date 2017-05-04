React = require('react')
isEmpty = require('lodash/isEmpty')
ui = require('../../lib/ui.coffee')
t = require('../../../lib/string-translation.js')('de')
PageHeader = require('../../ui-components/PageHeader.js')
PageContent = require('../PageContent.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')
f = require('lodash')
resourceTypeSwitcher = require('../../lib/resource-type-switcher.cjsx')


link = (c, h) ->
  <a href={h}>{c}</a>

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
      !kw.external_uri ? '' : link(kw.external_uri, kw.external_uri)
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


  getInitialState: ()-> {
    forUrl: libUrl.format(@props.get.keyword.resources.config.for_url)
  }
  componentDidMount: ()->
    @router =  require('../../../lib/router.coffee')
    @unlistenRouter = @router.listen((location) =>
      # NOTE: `location` has strange format, stringify it!
      @setState(forUrl: libUrl.format(location)))
    @router.start()

  componentWillUnmount: ()-> @unlistenRouter && @unlistenRouter()


  render: () ->

    get = @props.get

    { vocabulary, meta_key, keyword, contents_path } = get

    title = '"' + keyword.label + '"'

    switcher = resourceTypeSwitcher(get.keyword.resources, @state.forUrl, false, null)

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
          for_url={@props.for_url} withBox={true}
          get={get.keyword.resources} authToken={@props.authToken}
          mods={[ {bordered: false}, 'rounded-bottom' ]}
          toolBarMiddle={switcher}
          enableOrdering={true} />
      </div>
    </PageContent>


module.exports = VocabulariesShow
