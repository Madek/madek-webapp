/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Very minimal Dropdown, with pure-CSS fallback,
// receives toggle content via prop and menu as children.

// It's only responsible for toggling the menu via JS or CSS.

// NOTE: before implementing a more flexible version,
//       check if we could just port (and style!) from boostrap…
//       <https://github.com/react-bootstrap/react-bootstrap>

const React = require('react')
const { PropTypes } = React
const f = require('active-lodash')
const ui = require('../lib/ui.js')

const Icon = require('./Icon.jsx')
const Link = require('./Link.jsx')

const Dropdown = require('react-bootstrap/lib/Dropdown')
const MenuItem = require('react-bootstrap/lib/MenuItem')

const MODS = ['stick-right']

const UIDropdown = React.createClass({
  displayName: 'UI.Dropdown',
  propTypes: {
    toggle: PropTypes.string.isRequired,
    toggleProps: PropTypes.object,
    children: PropTypes.node,
    disabled: PropTypes.bool,
    startOpen: PropTypes.bool
  },

  getInitialState() {
    return { isClient: false }
  },
  componentDidMount() {
    return this.setState({ isClient: true })
  },

  fallbackStyles() {
    return (
      <style type="text/css">{`\
.ui-dropdown .dropdown-toggle { padding-bottom: 7px }
.dropdown:hover .dropdown-menu { display: block }\
`}</style>
    )
  },

  render(param) {
    if (param == null) {
      param = this
    }
    const { props, state } = param
    if (props.children.props.bsRole !== 'menu') {
      throw new Error('Missing or invalid Menu!')
    }

    const id = props.id || `${this.props.toggle}_menu`

    return (
      <Dropdown
        id={id}
        className={ui.cx(props.mods, 'ui-dropdown')}
        data-test-id={this.props.testId}>
        {!state.isClient ? this.fallbackStyles() : undefined}
        <Dropdown.Toggle
          {...Object.assign(
            {
              componentClass: Link,
              bsClass: 'dropdown-toggle ui-drop-toggle'
            },
            props.toggleProps
          )}>
          {props.toggle}
          <Icon i="arrow-down stand-alone small" />
        </Dropdown.Toggle>
        {props.children}
      </Dropdown>
    )
  }
})

UIDropdown.Menu = Dropdown.Menu
UIDropdown.MenuItem = function(props) {
  if (props == null) {
    ;({ props } = this)
  }
  const hasLink = f.present(props.href) || f.present(props.onClick)
  const isDisabled = f.present(props.disabled) ? props.disabled : !hasLink
  return (
    <MenuItem
      {...Object.assign(
        { componentClass: Link, className: 'ui-drop-item', disabled: isDisabled },
        props
      )}
    />
  )
}
module.exports = UIDropdown
