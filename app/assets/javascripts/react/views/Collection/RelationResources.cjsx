React = require('react')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')
ResourceThumbnail = require('../../decorators/ResourceThumbnail.cjsx')

classnames = require('classnames')

module.exports = React.createClass
  displayName: 'RelationResources'

  render: ({authToken, get, scope} = @props) ->

    titles = {
      parents: 'collection_relations_parent_sets'
      children: 'collection_relations_child_sets'
      siblings: 'collection_relations_sibling_sets'
    }

    <div className="ui-container tab-content bordered rounded-right rounded-bottom mbh">
      <div className="ui-container bright rounded-right rounded-bottom pal">

        <h2 className="ui-resources-header title-l separated mbl">
          {t(titles[scope])} <span className="ui-counter" style={{fontWeight: 'normal'}}>
            ({get.relation_resources.pagination.total_count})</span>
          <a className="strong" href="../relations">
            {t('collection_relations_show_all_relations')}
          </a>
        </h2>

        <MediaResourcesBox withBox={false}
          get={get.relation_resources} authToken={authToken}
          initial={ { show_filter: true } } mods={ [ {bordered: false}, 'rounded-bottom' ] }
          allowListMode={false}
          collectionData={{uuid: get.uuid, editable: false}} />
      </div>

    </div>
