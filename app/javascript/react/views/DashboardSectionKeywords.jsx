/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const cx = require('classnames')
const libUrl = require('url')
const qs = require('qs')
const PageContent = require('./PageContent.jsx')
const DashboardHeader = require('./DashboardHeader.jsx')
const t = require('../../lib/i18n-translate.js')
const Sidebar = require('./Sidebar.jsx')
const TagCloud = require('../ui-components/TagCloud.jsx')

module.exports = React.createClass({
  displayName: 'DashboardSectionKeywords',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { section, sectionResources } = param
    const keywords = f.map(sectionResources, keyword => {
      return {
        children: keyword.label + ' ',
        href: keyword.url,
        count: keyword.usage_count
      }
    })

    return (
      <div id={section.id}>
        <div className="ui-resources-header">
          <h2 className="title-l ui-resources-title">{section.title}</h2>
          {f.isEmpty(keywords) ? (
            <span style={{ marginLeft: '10px' }}>{t('dashboard_none_exist')}</span>
          ) : (
            <a className="strong" href={section.href}>
              {t('dashboard_show_all')}
            </a>
          )}
        </div>
        {!f.isEmpty(keywords) ? (
          <div className="ui-container pbh" style={{ paddingTop: '15px' }}>
            <TagCloud mod="label" list={keywords} />
          </div>
        ) : (
          undefined
        )}
      </div>
    )
  }
})
