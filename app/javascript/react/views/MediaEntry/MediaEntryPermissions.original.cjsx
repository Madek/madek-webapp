React = require('react')

ResourcePermissions = require('../../templates/ResourcePermissions.cjsx')

module.exports = React.createClass
  displayName: 'MediaEntryPermissions'
  propTypes:
    get: React.PropTypes.object.isRequired # just passed through

  render: (props = this.props)->
    <ResourcePermissions authToken={@props.authToken} get={props.get} />
