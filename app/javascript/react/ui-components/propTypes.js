import PropTypes from 'prop-types'

module.exports = {
  Clickable: PropTypes.shape({
    name: PropTypes.node.isRequired,
    isActive: PropTypes.bool,
    href: PropTypes.string,
    onClick: PropTypes.func
  }),

  Toggleable: PropTypes.shape({
    isActive: PropTypes.bool.isRequired,
    isDirty: PropTypes.bool,
    active: PropTypes.string,
    inactive: PropTypes.string,
    href: PropTypes.string,
    onClick: PropTypes.func
  })
}
