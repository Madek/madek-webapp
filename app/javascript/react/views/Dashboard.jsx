import React from 'react'
import PageContent from './PageContent.jsx'
import DashboardHeader from './DashboardHeader.jsx'
import Sidebar from './Sidebar.jsx'
import DashboardSectionKeywords from './DashboardSectionKeywords.jsx'
import DashboardSectionGroups from './DashboardSectionGroups.jsx'
import DashboardSectionResources from './DashboardSectionResources.jsx'

const Dashboard = ({ get, for_url }) => {
  const { user_dashboard, sections } = get
  const visible_sections = sections.filter(section => !section.hide_from_index)

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
            {visible_sections
              .map((section, index) => {
                let sectionComponent = null

                if (section.partial === 'media_resources') {
                  sectionComponent = (
                    <DashboardSectionResources section={section} url={get.url} key={index} />
                  )
                } else if (section.partial === 'groups') {
                  sectionComponent = (
                    <DashboardSectionGroups
                      section={section}
                      sectionResources={user_dashboard['groups_and_delegations']}
                      key={index}
                    />
                  )
                } else if (section.partial === 'keywords') {
                  sectionComponent = (
                    <DashboardSectionKeywords
                      section={section}
                      sectionResources={user_dashboard[section.id]}
                      key={index}
                    />
                  )
                }

                return [
                  sectionComponent,
                  index < visible_sections.length - 1 ? (
                    <hr className="separator mbm" key={`separator${index}`} />
                  ) : null
                ]
              })
              .flat()
              .filter(Boolean)}
          </div>
        </div>
      </div>
    </PageContent>
  )
}

export default Dashboard
module.exports = Dashboard
