/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import PageContent from './PageContent.jsx'
import DashboardHeader from './DashboardHeader.jsx'
import Sidebar from './Sidebar.jsx'
import DashboardSectionKeywords from './DashboardSectionKeywords.jsx'
import DashboardSectionGroups from './DashboardSectionGroups.jsx'
import DashboardSectionResources from './DashboardSectionResources.jsx'

module.exports = createReactClass({
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
