React = require('react')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')
ResourceThumbnail = require('../../decorators/ResourceThumbnail.cjsx')

classnames = require('classnames')

module.exports = React.createClass
  displayName: 'CollectionRelations'

  render: ({authToken, get} = @props) ->


    <div className="ui-container tab-content bordered rounded-right rounded-bottom mbh">
      <div className="ui-container bright rounded-right rounded-bottom pal">
        <div className="row">
          <div className="col6of6">
            <h2 className="title-m">
              {t('collection_relations_hint_text')}
            </h2>
          </div>
        </div>
      </div>
      <div className="ui-container midtone-darker bordered-bottom bordered-top relationships-wrapper">
        <div className="ui-resources-holder" id="set-relations-parents">
          <div className="ui-resources-header mbn">
            <h2 className="title-l ui-resource-title mtl mll">
              {t('collection_relations_parent_sets')}
              <span className="ui-counter">{'(' + f.size(get.relations.parent_collections.resources) + ')'}</span>
              {
                if false
                  <a className="strong" href="?type=parents">
                    Alle anzeigen
                  </a>
              }
            </h2>
          </div>
          <ul className="grid horizontal ui-resources">
            {
              if f.isEmpty(get.relations.parent_collections.resources)
                <div className="ui-container ptm pbh">
                  <div className="title-m by-center">{t('collection_relations_no_parent_sets')}</div>
                </div>
            }
            {
              f.map(get.relations.parent_collections.resources, (resource) ->
                <ResourceThumbnail key={resource.uuid} authToken={authToken} elm={'li'} get={resource}
                  style={{verticalAlign: 'top'}} />
              )
            }
          </ul>
        </div>
      </div>
      <div
        className={classnames(
          "bright relationships-this-wrapper relationships-wrapper ui-container",
          {'pointing-bottom': (get.type == 'Collection')})}
      >
        <div className="bordered-right bright pointing-right relationships-this ui-container">
          <div className="pointing-top">
            <div className="ui-resources-holder" id="set-relations-self">
              <div className="ui-resources-header mbn">
                <h2 className="title-l ui-resource-title mtl mll">
                  {
                    if get.type == 'Collection'
                      t('collection_relations_current_set')
                    else
                      t('collection_relations_current_media_entry')
                  }
                </h2>
              </div>
              <ul className="grid horizontal ui-resources">
                <ResourceThumbnail authToken={authToken} elm={'li'} get={get}
                  style={{verticalAlign: 'top'}} />
              </ul>
            </div>
          </div>
        </div>
        <div className="midtone relationships-siblings ui-container">
          <div className="ui-resources-holder" id="set-relations-siblings">
            <div className="ui-resources-header mbn">
              <h2 className="title-l ui-resource-title mtl mll">
                {t('collection_relations_sibling_sets')}
                <span className="ui-counter">{'(' + f.size(get.relations.sibling_collections.resources) + ')'}</span>
              </h2>
            </div>
            <ul className="grid horizontal ui-resources">
              {
                if f.isEmpty(get.relations.sibling_collections.resources)
                  <div className="ui-container ptm pbh">
                    <div className="title-m by-center">{t('collection_relations_no_sibling_sets')}</div>
                  </div>
              }
              {
                f.map(get.relations.sibling_collections.resources, (resource) ->
                  <ResourceThumbnail key={resource.uuid} authToken={authToken} elm={'li'} get={resource}
                    style={{verticalAlign: 'top'}} />
                )
              }
            </ul>
          </div>
        </div>
      </div>

      {
        if get.type == 'Collection'
          <div className="ui-container midtone-darker relationships-wrapper bordered-top">
            <div className="ui-resources-holder" id="set-relations-children">
              <div className="ui-resources-header mbn">
                <h2 className="title-l ui-resource-title mtl mll">
                  {t('collection_relations_child_sets')}
                  <span className="ui-counter">{'(' + f.size(get.relations.child_collections.resources) + ')'}</span>
                </h2>
              </div>
              <ul className="grid horizontal ui-resources">
                {
                  if f.isEmpty(get.relations.child_collections.resources)
                    <div className="ui-container ptm pbh">
                      <div className="title-m by-center">{t('collection_relations_no_child_sets')}</div>
                    </div>
                }
                {
                  f.map(get.relations.child_collections.resources, (resource) ->
                    <ResourceThumbnail key={resource.uuid} authToken={authToken} elm={'li'} get={resource} />
                  )
                }
              </ul>

            </div>
          </div>
      }
    </div>
