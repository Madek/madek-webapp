React = require('react')
isEmpty = require('lodash/isEmpty')
t = require('../../lib/string-translation.js')('de')
PageHeader = require('../ui-components/PageHeader.js')
PageContent = require('./PageContent.cjsx')
MediaResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')
f = require('lodash')
resourceTypeSwitcher = require('../lib/resource-type-switcher.cjsx')


infotable = (person) ->
  [
    [
      t('person_show_first_name'),
      person.first_name
    ],
    [
      t('person_show_last_name'),
      person.last_name
    ]
  ]


PersonShow = React.createClass
  displayName: 'PersonShow',

  getInitialState: ()-> {
    forUrl: libUrl.format(@props.for_url)
  }

  componentDidMount: ()->
    @router = require('../../lib/router.coffee')
    @unlistenRouter = @router.listen((location) =>
      # NOTE: `location` has strange format, stringify it!
      @setState(forUrl: libUrl.format(location)))
    @router.start()

  componentWillUnmount: ()-> @unlistenRouter && @unlistenRouter()

  render: ->
    get = @props.get
    title = get.to_s
    { resources } = get
    switcher = resourceTypeSwitcher(resources, @state.forUrl, false, null)

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
                        <td className='ui-summary-content'>{value}</td>
                      </tr>
                )
              }
            </tbody>
          </table>
        </div>
        <MediaResourcesBox
          for_url={@state.forUrl} withBox={true}
          get={resources} authToken={@props.authToken}
          mods={[ {bordered: false}, 'rounded-bottom' ]}
          toolBarMiddle={switcher}
          enableOrdering={true}
          enableOrderByTitle={true} />
      </div>
    </PageContent>

module.exports = PersonShow
