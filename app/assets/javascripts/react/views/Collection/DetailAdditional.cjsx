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
      <MediaResourcesBox withBox={true} get={get.relations.child_media_resources} authToken={authToken}
        initial={ { show_filter: false } } mods={ [ {bordered: false}, 'rounded-bottom' ] }/>
    </div>
