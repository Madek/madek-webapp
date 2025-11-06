import React from 'react'
import f from 'active-lodash'
import cx from 'classnames'
import t from '../../../lib/i18n-translate.js'
import ResourceThumbnail from '../../decorators/ResourceThumbnail.jsx'
import { parse as parseUrl, format as buildUrl } from 'url'

class Relations extends React.Component {
  render() {
    const { authToken, get } = this.props
    const typeKebab = f.kebabCase(get.type).replace('-', '_')

    const parentCount = get.relations.parent_collections.pagination.total_count
    const siblingCount = get.relations.sibling_collections.pagination.total_count

    return (
      <div
        className="ui-container tab-content bordered rounded-right rounded-bottom mbh"
        data-test-id={this.props.testId}>
        <div
          className="ui-container midtone-darker bordered-bottom bordered-top relationships-wrapper"
          style={{ border: '0px' }}>
          <div className="ui-resources-holder" id="set-relations-parents">
            <div className="ui-resources-header mbn">
              <h2 className="title-l ui-resource-title mtl mll">
                {t('collection_relations_parent_sets')}
                <span className="ui-counter">{`(${parentCount})`}</span>
                {parentCount > 0 ? (
                  <a className="strong" href={get.relations_parents_url}>
                    {t('collection_relations_show_all')}
                  </a>
                ) : undefined}
              </h2>
              <p className="mll mts">{t(typeKebab + '_relations_parents_hint')}</p>
            </div>
            <ul className="grid horizontal ui-resources">
              {parentCount === 0 ? (
                <div className="ui-container ptm pbh">
                  <div className="title-m by-center">
                    {t('collection_relations_no_parent_sets')}
                  </div>
                </div>
              ) : undefined}
              {f.map(get.relations.parent_collections.resources, resource => (
                <ResourceThumbnail
                  key={resource.uuid}
                  authToken={authToken}
                  elm="li"
                  get={resource}
                  style={{ verticalAlign: 'top' }}
                />
              ))}
            </ul>
          </div>
        </div>
        <div
          className={cx('bright relationships-this-wrapper relationships-wrapper ui-container', {
            'pointing-bottom': get.type === 'Collection'
          })}
          style={{ height: '360px' }}>
          <div
            className="bordered-right bright pointing-right relationships-this ui-container"
            style={{ height: '360px' }}>
            <div className="pointing-top">
              <div className="ui-resources-holder" id="set-relations-self">
                <div className="ui-resources-header mbn">
                  <h2 className="title-l ui-resource-title mtl mll">
                    {t(typeKebab + '_relations_current')}
                  </h2>
                  <p className="mll mts">&nbsp;</p>
                </div>
                <ul className="grid horizontal ui-resources">
                  <ResourceThumbnail
                    authToken={authToken}
                    elm="li"
                    get={get}
                    style={{ verticalAlign: 'top' }}
                  />
                </ul>
              </div>
            </div>
          </div>
          <div className="midtone relationships-siblings ui-container">
            <div className="ui-resources-holder" id="set-relations-siblings">
              <div className="ui-resources-header mbn">
                <h2 className="title-l ui-resource-title mtl mll">
                  {t('collection_relations_sibling_sets')}
                  <span className="ui-counter">{`(${siblingCount})`}</span>
                  {siblingCount > 0 ? (
                    <a className="strong" href={get.relations_siblings_url}>
                      {t('collection_relations_show_all')}
                    </a>
                  ) : undefined}
                </h2>
                <p className="mll mts">{t(typeKebab + '_relations_siblings_hint')}</p>
              </div>
              <ul className="grid horizontal ui-resources">
                {siblingCount === 0 ? (
                  <div className="ui-container ptm pbh">
                    <div className="title-m by-center">
                      {t('collection_relations_no_sibling_sets')}
                    </div>
                  </div>
                ) : undefined}
                {f.map(get.relations.sibling_collections.resources, resource => (
                  <ResourceThumbnail
                    key={resource.uuid}
                    authToken={authToken}
                    elm="li"
                    get={resource}
                    style={{ verticalAlign: 'top' }}
                  />
                ))}
              </ul>
            </div>
          </div>
        </div>
        {(() => {
          if (get.type === 'Collection') {
            const childCount = get.relations.child_collections.pagination.total_count
            let childUrl = parseUrl(get.url, true)
            delete childUrl.search
            childUrl.query['type'] = 'collections'
            childUrl = buildUrl(childUrl)

            return (
              <div className="ui-container midtone-darker relationships-wrapper bordered-top">
                <div className="ui-resources-holder" id="set-relations-children">
                  <div className="ui-resources-header mbn">
                    <h2 className="title-l ui-resource-title mtl mll">
                      {t('collection_relations_child_sets')}
                      <span className="ui-counter">{`(${childCount})`}</span>
                      {childCount > 0 ? (
                        <a className="strong" href={childUrl}>
                          {t('collection_relations_show_all')}
                        </a>
                      ) : undefined}
                    </h2>
                    <p className="mll mts">{t('collection_relations_children_hint')}</p>
                  </div>
                  <ul className="grid horizontal ui-resources">
                    {childCount === 0 ? (
                      <div className="ui-container ptm pbh">
                        <div className="title-m by-center">
                          {t('collection_relations_no_child_sets')}
                        </div>
                      </div>
                    ) : undefined}
                    {f.map(get.relations.child_collections.resources, resource => (
                      <ResourceThumbnail
                        key={resource.uuid}
                        authToken={authToken}
                        elm="li"
                        get={resource}
                        style={{ verticalAlign: 'top' }}
                      />
                    ))}
                  </ul>
                </div>
              </div>
            )
          }
        })()}
      </div>
    )
  }
}

export default Relations
