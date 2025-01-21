/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'

module.exports = createReactClass({
  displayName: 'ExploreLayout',

  getInitialState() {
    return { active: false }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { sections } = param
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
