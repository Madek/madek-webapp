import React from 'react'
import PropTypes from 'prop-types'
import ResourcePermissions from '../../templates/ResourcePermissions.jsx'

const MediaEntryPermissions = ({ authToken, get }) => {
  return <ResourcePermissions authToken={authToken} get={get} />
}

MediaEntryPermissions.propTypes = {
  get: PropTypes.object.isRequired
}

export default MediaEntryPermissions
module.exports = MediaEntryPermissions
