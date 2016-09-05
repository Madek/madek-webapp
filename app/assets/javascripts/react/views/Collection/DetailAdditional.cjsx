React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')

classnames = require('classnames')

module.exports = React.createClass
  displayName: 'CollectionDetailAdditional'
  render: ({get, authToken} = @props) ->
    <div className="ui-container rounded-bottom">
      <MediaResourcesBox collectionUuid={get.uuid} withBox={true}
        get={get.relations.child_media_resources} authToken={authToken}
        initial={ { show_filter: true } } mods={ [ {bordered: false}, 'rounded-bottom' ] }
        allowPinThumbs={true} allowListMode={true} />
    </div>
