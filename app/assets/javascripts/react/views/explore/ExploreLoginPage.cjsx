React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
classnames = require('classnames')
CatalogThumbnailShifted = require('./partials/CatalogThumbnailShifted.cjsx')
LoginMenu = require('../_layouts/LoginMenu.js').default
ResourcesSection = require('./partials/ResourcesSection.cjsx')

module.exports = React.createClass
  displayName: 'ExploreLoginPage'

  getInitialState: () -> { active: false }

  render: ({get, authToken} = @props) ->
    welcomeMessage = get.welcome_message

    sectionsElements =
      f.map get.sections, (section, m) ->
        <ResourcesSection key={'section_' + m} label={section.data.title} id={section.id}
          hrefUrl={section.data.url} showAllLink={section.show_all_link} section={section}
          showThumbDesc={true} />

    homeClaimPitchHero = <div className='ui-home-claim ui-container'>
      <div className='col2of3'>
        <div className='pitch-claim'>
          <h1 className='title-xxl'>
            {welcomeMessage.title}
          </h1>
          <div className='ptm' dangerouslySetInnerHTML={welcomeMessage.text} />
        </div>
      </div>
      <div className='col1of3'>
        <LoginMenu
          className='pitch-login'
          authToken={authToken}
        />
      </div>
    </div>


    <div>
      <div className="ui-collage crooked ui-container overlaid" id="teaser-set">

        {f.map f.chunk(f.slice(get.teaser_entries, 0, 20), 5), (chunk, row) ->
          <div key={'row_' + row} className="ui-collage-row">
            {f.map chunk, (resource, index) ->
              <CatalogThumbnailShifted key={'item_' + row + '_' + index} count={index + 1} imageUrl={resource.image_url} />
            }
          </div>
        }

        {homeClaimPitchHero}

      </div>

      <div className="app-body-ui-container pts context-home">

        {f.map sectionsElements, (section, index) ->
          list = [ ]
          separator = <hr key={'separator_' + index} className="separator"></hr>
          list.push(separator) if index > 0
          list.push(section)
          list
        }

      </div>
    </div>
