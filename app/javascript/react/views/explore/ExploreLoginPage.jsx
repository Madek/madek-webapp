import React from 'react'
import LoginMenu from '../_layouts/LoginMenu.js'
import ResourcesSection from './partials/ResourcesSection.jsx'

const ExploreLoginPage = ({ get, lang }) => {
  const welcomeMessage = get.welcome_message

  const sectionsElements = get.sections
    .map((section, m) => {
      if (section['empty?']) {
        return null
      }
      return (
        <ResourcesSection
          key={`section_${m}`}
          label={section.content.data.title}
          id={section.content.id}
          hrefUrl={section.content.data.url}
          showAllLink={section.content.show_all_link}
          section={section.content}
        />
      )
    })
    .filter(Boolean)

  const outerStyle = {}

  const claimStyle = {
    margin: '0px',
    padding: '20px',
    marginLeft: 'auto',
    marginRight: 'auto',
    border: '0px',
    boxShadow: 'none',
    paddingTop: '40px',
    width: '1000px',
    paddingLeft: '0px',
    paddingRight: '0px',
    background: 'none'
  }

  const pitchClaimStyle = {
    paddingLeft: '0px'
  }

  const homeClaimPitchHero = get.show_login ? (
    <div style={outerStyle}>
      <div style={claimStyle}>
        <div className="col2of3">
          <div style={pitchClaimStyle} className="pitch-claim">
            <h1 className="title-xxl">{welcomeMessage.title}</h1>
            <div className="ptm" dangerouslySetInnerHTML={welcomeMessage.text} />
          </div>
        </div>
        <div className="col1of3">
          <LoginMenu lang={lang} returnTo="/" />
        </div>
        <div style={{ clear: 'both' }} />
      </div>
    </div>
  ) : (
    <div style={outerStyle}>
      <div style={claimStyle}>
        <div>
          <div style={pitchClaimStyle} className="pitch-claim">
            <h1 className="title-xxl">{welcomeMessage.title}</h1>
            <div className="ptm" dangerouslySetInnerHTML={welcomeMessage.text} />
          </div>
        </div>
        <div style={{ clear: 'both' }} />
      </div>
    </div>
  )

  return (
    <div>
      {homeClaimPitchHero}
      <div className="app-body-ui-container pts context-home">
        <hr className="separator" />
        {sectionsElements.map((section, index) => {
          const list = []
          const separator = <hr key={`separator_${index}`} className="separator" />
          if (index > 0) {
            list.push(separator)
          }
          list.push(section)
          return list
        })}
      </div>
    </div>
  )
}

export default ExploreLoginPage
module.exports = ExploreLoginPage
