/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')

const ResourcesBoxWithSwitch = require('../../templates/ResourcesBoxWithSwitch.jsx')

module.exports = React.createClass({
  displayName: 'Views.MediaEntry.Index',
  propTypes: {
    for_url: React.PropTypes.string.isRequired,
    // all other props are just passed through to ResourcesBox:
    get: React.PropTypes.object.isRequired
  },

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    return (
      <ResourcesBoxWithSwitch
        {...Object.assign(
          { saveable: true, switches: { currentType: 'entries', otherTypes: ['sets'] } },
          props,
          { enableOrdering: true, enableOrderByTitle: true, usePathUrlReplacement: true }
        )}
      />
    )
  }
})
