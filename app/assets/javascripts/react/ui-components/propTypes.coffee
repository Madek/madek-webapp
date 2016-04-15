React = require('react')

module.exports =
  Clickable: React.PropTypes.shape
    name: React.PropTypes.node.isRequired
    isActive: React.PropTypes.bool
    href: React.PropTypes.string
    onClick: React.PropTypes.func

  Toggleable: React.PropTypes.shape
    isActive: React.PropTypes.bool.isRequired
    isDirty: React.PropTypes.bool
    active: React.PropTypes.string
    inactive: React.PropTypes.string
    href: React.PropTypes.string
    onClick: React.PropTypes.func
