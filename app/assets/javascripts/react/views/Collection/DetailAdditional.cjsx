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
qs = require('qs')

module.exports = React.createClass
  displayName: 'CollectionDetailAdditional'

  getInitialState: ()-> {
    forUrl: libUrl.format(@props.get.child_media_resources.config.for_url)
  }
  componentDidMount: ()->
    @router =  require('../../../lib/router.coffee')
    @unlistenRouter = @router.listen((location) =>
      # NOTE: `location` has strange format, stringify it!
      @setState(forUrl: libUrl.format(location)))
    @router.start()

  componentWillUnmount: ()-> @unlistenRouter && @unlistenRouter()

  render: ({get, authToken} = @props) ->
    resourceTypeSwitcher = () =>
      listConfig = get.child_media_resources.config
      currentType = qs.parse(libUrl.parse(@state.forUrl).query).type
      typeBbtns = f.compact([
        {key: 'all', name: 'Alle'},
        {key: 'entries', name: t('sitemap_entries')},
        {key: 'collections', name: t('sitemap_collections')}])

      return (<ButtonGroup>{typeBbtns.map (btn) =>
        isActive = currentType == btn.key || !currentType && btn.key == 'all'
        btnUrl = setUrlParams(@state.forUrl, {type: btn.key})

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
        collectionData={{uuid: get.uuid, layout: get.layout, editable: get.editable, order: get.sorting}}
        toolBarMiddle={resourceTypeSwitcher()}
        enableOrdering={true} enableOrderByTitle={true}
        />
    </div>
