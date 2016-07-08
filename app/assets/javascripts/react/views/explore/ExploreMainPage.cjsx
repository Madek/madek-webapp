React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
ExploreLayout = require('../../decorators/ExploreLayout.cjsx')
ExploreMenu = require('./partials/ExploreMenu.cjsx')
ExploreMenuEntry = require('./partials/ExploreMenuEntry.cjsx')
ExploreMenuSection = require('./partials/ExploreMenuSection.cjsx')
ResourcesSection = require('./partials/ResourcesSection.cjsx')

module.exports = React.createClass
  displayName: 'ExploreMainPage'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->

    resourcesSections =

      f.map get.sections, (section, m) ->
        <ResourcesSection key={'section_' + m} label={section.data.title}
          hrefUrl={section.data.url} showAllLink={section.show_all_link} section={section} authToken={authToken} />


    menu =
      <ExploreMenu authToken={authToken} >
        {f.map get.nav, (section) ->
          <ExploreMenuSection key={section.url} label={section.title} hrefUrl={section.url} active={section.active}>
            {f.map section.children, (entry) ->
              <ExploreMenuEntry key={entry.url} label={entry.title} hrefUrl={entry.url} active={entry.active} />
            }
          </ExploreMenuSection>
        }
      </ExploreMenu>

    <ExploreLayout {...@props} pageTitle={get.page_title} menu={menu} sections={resourcesSections}
      collageResources={get.teaser_entries} authToken={authToken} />
