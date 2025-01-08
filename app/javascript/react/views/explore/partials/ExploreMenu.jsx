/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')

module.exports = React.createClass({
  displayName: 'ExploreMenu',
  render(...args) {
    const val = args[0],
      obj = val != null ? val : this.props
    const index = 0
    return (
      <div className="app-body-sidebar bright ui-container table-cell bordered-right rounded-bottom-left table-side">
        <div className="ui-container rounded-left phm pvl">
          <ul className="ui-side-navigation">
            {f.map(this.props.children, function(child, index) {
              const list = []
              const separator = <li key={`separator_${index}`} className="separator mini" />
              if (index > 0) {
                list.push(separator)
              }
              list.push(child)
              return list
            })}
          </ul>
        </div>
      </div>
    )
  }
})
