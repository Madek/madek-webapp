/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const cx = require('classnames')
const libUrl = require('url')
const qs = require('qs')
const PageContent = require('./PageContent.cjsx')
const DashboardHeader = require('./DashboardHeader.cjsx')
const t = require('../../lib/i18n-translate.js')
const Sidebar = require('./Sidebar.cjsx')
const TagCloud = require('../ui-components/TagCloud.cjsx')
const DashboardSectionKeywords = require('./DashboardSectionKeywords.cjsx')
const DashboardSectionGroups = require('./DashboardSectionGroups.cjsx')
const DashboardSectionResources = require('./DashboardSectionResources.cjsx')

module.exports = React.createClass({
  displayName: 'Dashboard',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, for_url } = param
    const { user_dashboard } = get
    const { sections } = get

    const visible_sections = f.reject(sections, { hide_from_index: true })

    return (
      <PageContent>
        <DashboardHeader get={user_dashboard.dashboard_header} />
        <div className="ui-container midtone bordered rounded-right rounded-bottom table">
          <div className="ui-container app-body-sidebar table-cell bright bordered-right rounded-bottom-left table-side">
            <div className="ui-container rounded-bottom-left phm pvl">
              <Sidebar sections={sections} for_url={for_url} />
            </div>
          </div>
          <div className="ui-container app-body-content table-cell table-substance">
            <div className="ui-container pal">
              {f.flatten(
                f.map(visible_sections, (section, index) => {
                  return f.compact([
                    (() => {
                      if (section.partial === 'media_resources') {
                        return (
                          <DashboardSectionResources
                            section={section}
                            url={this.props.get.url}
                            key={index}
                          />
                        )
                      } else if (section.partial === 'groups') {
                        return (
                          <DashboardSectionGroups
                            section={section}
                            sectionResources={user_dashboard['groups_and_delegations']}
                            key={index}
                          />
                        )
                      } else if (section.partial === 'keywords') {
                        return (
                          <DashboardSectionKeywords
                            section={section}
                            sectionResources={user_dashboard[section.id]}
                            key={index}
                          />
                        )
                      }
                    })(),
                    index < visible_sections.length - 1 ? (
                      <hr className="separator mbm" key={`separator${index}`} />
                    ) : (
                      undefined
                    )
                  ])
                })
              )}
            </div>
          </div>
        </div>
      </PageContent>
    )
  }
})
