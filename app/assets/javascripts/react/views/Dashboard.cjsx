React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
cx = require('classnames')
libUrl = require('url')
qs = require('qs')
PageContent = require('./PageContent.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
DashboardHeader = require('./DashboardHeader.cjsx')
t = require('../../lib/i18n-translate.js')
Sidebar = require('./Sidebar.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')
DashboardSectionKeywords = require('./DashboardSectionKeywords.cjsx')
DashboardSectionGroups = require('./DashboardSectionGroups.cjsx')
DashboardSectionResources = require('./DashboardSectionResources.cjsx')

module.exports = React.createClass
  displayName: 'Dashboard'

  render: ({get, for_url} = @props) ->

    user_dashboard = get.user_dashboard
    sections = get.sections

    visible_sections = f.reject(sections, {hide_from_index: true})

    <PageContent>

      <DashboardHeader get={user_dashboard.dashboard_header} />

      <div className='ui-container midtone bordered rounded-right rounded-bottom table'>

        <div className='ui-container app-body-sidebar table-cell bright bordered-right rounded-bottom-left table-side'>
          <div className='ui-container rounded-bottom-left phm pvl'>

            <Sidebar sections={sections} for_url={for_url} />
          </div>

        </div>

        <div className='ui-container app-body-content table-cell table-substance'>
          <div className='ui-container pal'>

            {
              f.flatten(f.map(visible_sections, (section, index) =>

                f.compact([
                  if section.partial == 'media_resources'
                    <DashboardSectionResources section={section} url={@props.get.url} key={index} />
                  else if section.partial == 'groups'
                    <DashboardSectionGroups
                      section={section}
                      sectionResources={user_dashboard['groups_and_delegations']}
                      key={index}
                    />
                  else if section.partial == 'keywords'
                    <DashboardSectionKeywords section={section} sectionResources={user_dashboard[section.id]} key={index} />
                  ,
                  if index < visible_sections.length - 1
                    <hr className='separator mbm' key={'separator' + index} />
                ])
              ))
            }

          </div>
        </div>
      </div>

    </PageContent>
