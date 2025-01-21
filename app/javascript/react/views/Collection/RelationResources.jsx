/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate.js'
import MediaResourcesBox from '../../decorators/MediaResourcesBox.jsx'

module.exports = createReactClass({
  displayName: 'RelationResources',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get, scope } = param
    const typeKebab = f.kebabCase(get.type).replace('-', '_')

    const titles = {
      parents: 'collection_relations_parent_sets',
      siblings: 'collection_relations_sibling_sets',
      children: 'collection_relations_child_sets'
    }

    const hints = {
      parents: typeKebab + '_relations_parents_hint',
      siblings: typeKebab + '_relations_siblings_hint'
    }

    return (
      <div
        className="ui-container tab-content bordered rounded-right rounded-bottom mbh"
        data-test-id={this.props.testId}>
        <div className="ui-container bright rounded-right rounded-bottom phl ptl">
          <h2 className="ui-resources-header title-l separated mbm">
            {t(titles[scope])}{' '}
            <span className="ui-counter" style={{ fontWeight: 'normal' }}>
              {`\
(`}
              {get.relation_resources.pagination.total_count})
            </span>
            <a className="strong" href={get.relations_url}>
              {t('collection_relations_show_all_relations')}
            </a>
          </h2>
          <p className="mbm mts">{t(hints[scope])}</p>
        </div>
        <MediaResourcesBox
          get={get.relation_resources}
          authToken={authToken}
          initial={{ show_filter: true }}
          mods={[{ bordered: false }, 'rounded-bottom']}
          enableOrdering={true}
          enableOrderByTitle={true}
        />
      </div>
    )
  }
})
