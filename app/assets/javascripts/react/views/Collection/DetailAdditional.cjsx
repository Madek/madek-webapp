React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
classnames = require('classnames')
t = require('../../../lib/i18n-translate.js')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')
LoadXhr = require('../../../lib/load-xhr.coffee')
resourceTypeSwitcher = require('../../lib/resource-type-switcher.cjsx')
libUrl = require('url')

module.exports = React.createClass
  displayName: 'CollectionDetailAdditional'

  forUrl: () ->
    libUrl.format(@props.get.child_media_resources.config.for_url)

  render: ({get, authToken} = @props) ->

    renderSwitcher = (boxUrl) =>
      resourceTypeSwitcher(get.child_media_resources, boxUrl, true, null)

    <div className="ui-container rounded-bottom">
      <MediaResourcesBox
        get={get.child_media_resources} authToken={authToken}
        initial={ { show_filter: true } } mods={ [ {bordered: false}, 'rounded-bottom' ] }
        collectionData={{uuid: get.uuid, layout: get.layout, editable: get.editable, order: get.sorting, url: get.url, batchEditUrl: get.batch_edit_url}}
        renderSwitcher={renderSwitcher}
        enableOrdering={true} enableOrderByTitle={true}
        showAllButton={true}
        />
    </div>
