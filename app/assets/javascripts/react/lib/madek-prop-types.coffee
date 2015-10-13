PropTypes = require('react').PropTypes

MadekPropTypes = M = {}

M.metaKey = PropTypes.shape
  label: PropTypes.string.isRequired
  description: PropTypes.string
  hint: PropTypes.string

M.metaDatum =  PropTypes.shape
  meta_key: M.metaKey

module.exports = MadekPropTypes
