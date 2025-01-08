/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')

const ResourcePermissions = require('../../templates/ResourcePermissions.jsx')

module.exports = React.createClass({
  displayName: 'MediaEntryPermissions',
  propTypes: {
    get: React.PropTypes.object.isRequired
  }, // just passed through

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    return <ResourcePermissions authToken={this.props.authToken} get={props.get} />
  }
})
