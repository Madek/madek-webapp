/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import ResourcesBoxWithSwitch from '../../templates/ResourcesBoxWithSwitch.jsx'

module.exports = createReactClass({
  displayName: 'Views.MediaEntry.Index',
  propTypes: {
    for_url: PropTypes.string.isRequired,
    // all other props are just passed through to ResourcesBox:
    get: PropTypes.object.isRequired
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
