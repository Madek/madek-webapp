React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')
LoadXhr = require('../../../lib/load-xhr.coffee')
setUrlParams = require('../../../lib/set-params-for-url.coffee')


classnames = require('classnames')

module.exports = React.createClass
  displayName: 'CollectionDetailAdditional'

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
    <div className="ui-container rounded-bottom">
      <MediaResourcesBox withBox={true}
        get={get.child_media_resources} authToken={authToken}
        initial={ { show_filter: true } } mods={ [ {bordered: false}, 'rounded-bottom' ] }
        allowListMode={true}
        collectionData={{uuid: get.uuid, layout: get.layout, editable: get.editable, order: get.sorting}}
        loadChildMediaResources={@_loadChildMediaResources} />
    </div>
