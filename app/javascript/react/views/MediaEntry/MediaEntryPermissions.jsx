/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import ResourcePermissions from '../../templates/ResourcePermissions.jsx'

module.exports = createReactClass({
  displayName: 'MediaEntryPermissions',
  propTypes: {
    get: PropTypes.object.isRequired
  }, // just passed through

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    return <ResourcePermissions authToken={this.props.authToken} get={props.get} />
  }
})
