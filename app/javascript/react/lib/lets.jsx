// import React from 'react'
import PropTypes from 'prop-types'

// usage: <Let one=1 lang={getLang()}>{({one,lang}) => <span>{one}{lang}</span>}</Let>
const Let = ({ children, ...bindings }) => children(bindings)

// usage: <IfLet lang={getLang()}>{lang => <span>{lang}</span>}</IfLet>
const IfLet = ({ children, ...bindings }) => {
  const keys = Object.keys(bindings)
  if (keys.length > 1) throw new TypeError('IfLet requires 0 or 1 bindings!')
  const binding = bindings[keys[0]]
  return binding ? children(binding) : null
}
IfLet.propTypes = {
  children: PropTypes.func.isRequired
}

module.exports.Let = Let
module.exports.IfLet = IfLet
