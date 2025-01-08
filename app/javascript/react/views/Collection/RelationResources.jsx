/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const t = require('../../../lib/i18n-translate.js')
const MediaResourcesBox = require('../../decorators/MediaResourcesBox.jsx')
const TabContent = require('../TabContent.jsx')
const ResourceThumbnail = require('../../decorators/ResourceThumbnail.jsx')

const classnames = require('classnames')

module.exports = React.createClass({
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
