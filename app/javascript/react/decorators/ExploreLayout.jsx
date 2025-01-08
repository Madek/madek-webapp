/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const PrettyThumbs = require('../views/explore/partials/PrettyThumbs.jsx')

module.exports = React.createClass({
  displayName: 'ExploreLayout',

  getInitialState() {
    return { active: false }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, sections, collageResources, pageTitle } = param
    return (
      <div>
        <div className="app-body-ui-container pts context-home" style={{ width: '1000px' }}>
          <a className="strong" style={{ position: 'relative', top: '20px' }} href="/explore">{`\
Zurück\
`}</a>
          {f.map(sections, function(section, index) {
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
