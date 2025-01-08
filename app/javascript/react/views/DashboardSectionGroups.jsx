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
  displayName: 'DashboardSectionGroups',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { section, sectionResources } = param
    const group_types = f.zipObject(
      f.map(
        {
          internal: t('internal_groups'),
          delegations: t('responsibility_groups'),
          authentication: t('authentication_groups'),
          external: t('external_groups')
        },
        function(label, type) {
          const groups = f.map(sectionResources[type], entry => ({
            children: entry.detailed_name,
            href: entry.url
          }))
          return [type, { label, list: groups }]
        }
      )
    )

    return (
      <div id={section.id}>
        <div className="ui-resources-header">
          <h2 className="title-l ui-resources-title">{section.title}</h2>
          <a className="strong" href={section.href}>
            {t('dashboard_show_all')}
          </a>
        </div>
        <div className="ui-container pbl">
          {f.map(group_types, function(groups, type) {
            if (groups.list) {
              return (
                <label className="ui-form-group columned phn" key={type}>
                  <div className="form-label">{groups.label}</div>
                  {f.isEmpty(groups.list) ? (
                    <div className="form-item" style={{ paddingTop: '5px' }}>
                      {t('dashboard_none_exist')}
                    </div>
                  ) : (
                    <div className="form-item">
                      <TagCloud mod="label" list={groups.list} />
                    </div>
                  )}
                </label>
              )
            }
          })}
        </div>
      </div>
    )
  }
})
