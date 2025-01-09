/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const classnames = require('classnames')
const LoginMenu = require('../_layouts/LoginMenu.js').default
const ResourcesSection = require('./partials/ResourcesSection.jsx')

module.exports = React.createClass({
  displayName: 'ExploreLoginPage',

  getInitialState() {
    return { active: false }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, authToken, authStep2Path, lang } = param
    const welcomeMessage = get.welcome_message

    const sectionsElements = f.compact(
      f.map(get.sections, function(section, m) {
        if (section['empty?']) {
          return
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
    )
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
          {f.map(sectionsElements, function(section, index) {
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
})
