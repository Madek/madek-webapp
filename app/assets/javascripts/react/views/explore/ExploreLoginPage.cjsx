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

  render: ({get, loginProviders, authToken} = @props) ->
    welcomeMessage = get.welcome_message

    sectionsElements =
      f.compact(
        f.map get.sections, (section, m) ->
          return if section['empty?']
          <ResourcesSection key={'section_' + m} label={section.content.data.title} id={section.content.id}
            hrefUrl={section.content.data.url} showAllLink={section.content.show_all_link} section={section.content} />
      )
    outerStyle = {
      paddingBottom: '10px'
    }

    if !get.show_login
      outerStyle.height = '180px'

    claimStyle = {
      position: 'static'
      margin: '0px'
      padding: '20px'
      marginLeft: 'auto'
      marginRight: 'auto'
      border: '0px'
      boxShadow: 'none'
      paddingTop: '40px'
      width: '1000px'
      paddingLeft: '0px'
      paddingRight: '0px'
      background: 'none'
    }

    pitchClaimStyle = {
      paddingLeft: '0px'
    }

    homeClaimPitchHero = if get.show_login
        <div style={outerStyle}>
          <div style={claimStyle} className='ui-home-claim ui-container'>
            <div className='col2of3'>
              <div style={pitchClaimStyle} className='pitch-claim'>
                <h1 className='title-xxl'>
                  {welcomeMessage.title}
                </h1>
                <div className='ptm' dangerouslySetInnerHTML={welcomeMessage.text} />
              </div>
            </div>
            <div className='col1of3'>
              <LoginMenu
                loginProviders={loginProviders}
                authToken={authToken}
              />
            </div>
          </div>
        </div>
      else
        <div style={outerStyle}>
          <div style={claimStyle} className='ui-home-claim ui-container'>
            <div>
              <div style={pitchClaimStyle} className='pitch-claim'>
                <h1 className='title-xxl'>
                  {welcomeMessage.title}
                </h1>
                <div className='ptm' dangerouslySetInnerHTML={welcomeMessage.text} />
              </div>
            </div>
          </div>
        </div>

    <div>
      {
        homeClaimPitchHero
      }

      <div className="app-body-ui-container pts context-home">

        <hr className='separator' />

        {f.map sectionsElements, (section, index) ->
          list = [ ]
          separator = <hr key={'separator_' + index} className="separator"></hr>
          list.push(separator) if index > 0
          list.push(section)
          list
        }

      </div>
    </div>
