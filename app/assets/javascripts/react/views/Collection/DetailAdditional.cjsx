React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
classnames = require('classnames')
t = require('../../../lib/string-translation.js')('de')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')
LoadXhr = require('../../../lib/load-xhr.coffee')
setUrlParams = require('../../../lib/set-params-for-url.coffee')

Button = require('../../ui-components/Button.cjsx')
ButtonGroup = require('../../ui-components/ButtonGroup.cjsx')

libUrl = require('url')

module.exports = React.createClass
  displayName: 'CollectionDetailAdditional'

  getInitialState: ()-> {}
  componentDidMount: ()->
    @router =  require('../../../lib/router.coffee')
    @setState(forUrl: @props.get.child_media_resources.config.for_url)
    @unlistenRouter = @router.listen((location) =>
      # NOTE: `location` has strange format (search instead of query attrs)
      forUrl = libUrl.parse(libUrl.format(location))
      @setState(forUrl: forUrl))
    @router.start()

  componentWillUnmount: ()-> @unlistenRouter && @unlistenRouter()

  _loadChildMediaResources: (itemKey, callback) ->

    get = @props.get

    sparseParam = {___sparse: { child_media_resources: {} }}
    listParam = list: {order: itemKey}

    url = setUrlParams(get.url + '.json', sparseParam, listParam)

    LoadXhr({
      method: 'GET',
      url: url
    },
    (result, json) ->
      callback(json.child_media_resources)
    )

  render: ({get, authToken} = @props) ->
    resourceTypeSwitcher = () =>
      listConfig = get.child_media_resources.config
      currentType = listConfig.for_url.query.type
      typeBbtns = f.compact([
        {key: 'all', name: 'Alle'},
        {key: 'entries', name: t('sitemap_entries')},
        {key: 'collections', name: t('sitemap_collections')}])

      return (<ButtonGroup>{typeBbtns.map (btn) =>
        isActive = currentType == btn.key || !currentType && btn.key == 'all'
        btnUrl = setUrlParams(@state.forUrl, {type: btn.key})
        console.log 'btnUrl', btnUrl, @state.forUrl
        <Button {...btn}
          onClick={@_onResourceSwitch}
          href={btnUrl}
          mods={if isActive then 'active'}>
          {btn.name}
        </Button>}
      </ButtonGroup>)

    <div className="ui-container rounded-bottom">
      <MediaResourcesBox withBox={true}
        get={get.child_media_resources} authToken={authToken}
        router={@router}
        initial={ { show_filter: true } } mods={ [ {bordered: false}, 'rounded-bottom' ] }
        allowListMode={true}
        collectionData={{uuid: get.uuid, layout: get.layout, editable: get.editable, order: get.sorting}}
        loadChildMediaResources={@_loadChildMediaResources}
        toolBarMiddle={resourceTypeSwitcher()} />
    </div>
