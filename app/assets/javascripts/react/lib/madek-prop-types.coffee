f = require('active-lodash')
PropTypes = require('react').PropTypes
validateUUID = require('uuid-validate')

# Define all PropTypes that directly relate to Models/Presenters here.
# NOTE: Never set the top-level as `isRequired`, that is up to the Component!

# # Constants
NAMESPACE_MATCH = '[a-z0-9\-_]+'
VOCABULARY_REGEX = RegExp("^#{NAMESPACE_MATCH}$")
MKEY_REGEX = RegExp("^#{NAMESPACE_MATCH}:#{NAMESPACE_MATCH}$")
META_DATUM_TYPES = [
    'MetaDatum::Text', 'MetaDatum::TextDate',
    'MetaDatum::People', 'MetaDatum::Groups'
    'MetaDatum::Keywords', 'MetaDatum::Licenses'
  ]

# Set up base object, so that each single definition is standalone
# and can be included/nested once defined. Shortcut just for readabilty here.
MadekPropTypes = M = {}

# Basics
M.uuid = (props, propName, _componentName)->
  if not validateUUID(props[propName], 4)
    return new Error('Malformed uuid!')

M.metaKeyId = (props, propName, _componentName)->
  if not MKEY_REGEX.test(props[propName])
    return new Error('Malformed metaKeyId!')

# Resources
M.metaKey = PropTypes.shape
  label: PropTypes.string.isRequired
  description: PropTypes.string
  hint: PropTypes.string

M.metaDatum =  PropTypes.shape
  meta_key: M.metaKey

# ResourceFilters
# NOTE: extracted only for readabilty
# comments refer to <http://madek.readthedocs.org/en/latest/filters/>
ResourceFiltersMetaData = f.values
  # 1
  keyUuid: PropTypes.shape(
    key: PropTypes.string.isRequired
    value: M.uuid.isRequired)
  # 2
  keyMatch: PropTypes.shape(
    key: M.metaKeyId.isRequired
    match: PropTypes.string.isRequired)
  # 3
  searchKeyType: PropTypes.shape(
    key: PropTypes.oneOf(['any']).isRequired
    match: PropTypes.string.isRequired,
    type: PropTypes.oneOf(META_DATUM_TYPES).isRequired)
  # 4
  searchKey: PropTypes.shape(
    key: PropTypes.oneOf(['any']).isRequired
    match: PropTypes.string.isRequired)
  # 5
  hasKey: PropTypes.shape(
    key: M.metaKeyId.isRequired)
  # 6
  notKey: PropTypes.shape(
    not_key: M.metaKeyId.isRequired)

M.resourceFilter = PropTypes.shape
  search: PropTypes.string
  meta_data: PropTypes.arrayOf(PropTypes.oneOfType(ResourceFiltersMetaData))
  media_files: PropTypes.arrayOf(
    PropTypes.shape(
      key: PropTypes.string.isRequired
      value: PropTypes.string.isRequired))
  permissions: PropTypes.arrayOf(
    PropTypes.oneOfType([
      PropTypes.shape(
        key: PropTypes.oneOf([
          'responsible_user',
          'entrusted_to_user',
          'entrusted_to_group']).isRequired
        value: M.uuid.isRequired),
      PropTypes.shape(
        key: PropTypes.oneOf(['public']).isRequired
        value: PropTypes.oneOf([true, false]).isRequired)]))

# DynamicFilters

module.exports = MadekPropTypes
