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

    typeKebab = f.kebabCase(get.type).replace('-', '_')

    titles = {
      parents: 'collection_relations_parent_sets'
      siblings: 'collection_relations_sibling_sets'
      children: 'collection_relations_child_sets'
    }

    hints = {
      parents: typeKebab + '_relations_parents_hint'
      siblings: typeKebab + '_relations_siblings_hint'
    }

    <div className="ui-container tab-content bordered rounded-right rounded-bottom mbh" data-test-id={@props.testId}>
      <div className="ui-container bright rounded-right rounded-bottom phl ptl">

        <h2 className="ui-resources-header title-l separated mbm">
          {t(titles[scope])} <span className="ui-counter" style={{fontWeight: 'normal'}}>
            ({get.relation_resources.pagination.total_count})</span>
          <a className="strong" href="../relations">
            {t('collection_relations_show_all_relations')}
          </a>
        </h2>
        <p className='mbm mts'>
          {t(hints[scope])}
        </p>
      </div>

      <MediaResourcesBox withBox={true}
        get={get.relation_resources} authToken={authToken}
        mods={[ {bordered: false}, 'rounded-bottom' ]}
        allowListMode={false}
        collectionData={{uuid: get.uuid, editable: false}}
      />

    </div>
