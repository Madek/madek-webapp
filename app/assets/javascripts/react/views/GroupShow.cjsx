React = require('react')
isEmpty = require('lodash/isEmpty')
ui = require('../lib/ui.coffee')
t = require('../../lib/string-translation.js')('de')
PageHeader = require('../ui-components/PageHeader.js')
PageContent = require('./PageContent.cjsx')
MediaResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')
f = require('lodash')
resourceTypeSwitcher = require('../lib/resource-type-switcher.cjsx')
parseUrl = require('url').parse
parseQuery = require('qs').parse
setUrlParams = require('../../lib/set-params-for-url.coffee')


link = (c, h) ->
  <a href={h}>{c}</a>

infotable = (group) ->
  f.compact([
    [
      t('group_meta_data_name'),
      group.name
    ],
    [
      t('group_meta_data_institutional_group_name'),
      group.institutional_group_name
    ] if group.institutional_group_name,
  ])

GroupShow = React.createClass
  displayName: 'GroupShow',


  getInitialState: ()-> {
    forUrl: libUrl.format(@props.get.resources.config.for_url)
  }
  componentDidMount: ()->
    @router =  require('../../lib/router.coffee')
    @unlistenRouter = @router.listen((location) =>
      # NOTE: `location` has strange format, stringify it!
      @setState(forUrl: libUrl.format(location)))
    @router.start()

  componentWillUnmount: ()-> @unlistenRouter && @unlistenRouter()


  render: () ->

    get = @props.get

    group = get.group

    title = '"' + group.name + '"'

    switcher = resourceTypeSwitcher(get.resources, @state.forUrl, false, null)

    headerActions = if get.group.edit_url
      <a href={get.group.edit_url} className='primary-button'>
        {t('group_show_edit_button')}
      </a>

    <PageContent>
      <PageHeader title={title} icon='privacy-group' actions={headerActions} />
      <div className='ui-container tab-content bordered bright rounded-right rounded-bottom'>
        <div className='ui-container pal'>
          <table className='borderless'>
            <tbody>
              {
                f.map(
                  infotable(group),
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
          get={get.resources} authToken={@props.authToken}
          mods={[ {bordered: false}, 'rounded-bottom' ]}
          toolBarMiddle={switcher}
          enableOrdering={true} />
      </div>
    </PageContent>


module.exports = GroupShow
