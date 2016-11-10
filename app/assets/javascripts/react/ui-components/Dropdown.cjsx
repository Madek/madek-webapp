# Very minimal Dropdown, with pure-CSS fallback,
# receives toggle content via prop and menu as children.

# It's only responsible for toggling the menu via JS or CSS.

# NOTE: before implementing a more flexible version,
#       check if we could just port (and style!) from boostrap…
#       <https://github.com/react-bootstrap/react-bootstrap>

React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
ui = require('../lib/ui.coffee')

Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')

Dropdown = require('react-bootstrap/lib/Dropdown')
MenuItem = require('react-bootstrap/lib/MenuItem')

MODS = ['stick-right'] # TODO: check and validate supported mods

UIDropdown = React.createClass
  displayName: 'UI.Dropdown'
  propTypes:
    toggle: PropTypes.string.isRequired
    toggleProps: PropTypes.object
    children: PropTypes.node
    disabled:  PropTypes.bool
    startOpen: PropTypes.bool

  getInitialState: ()-> { isClient: false }
  componentDidMount: ()-> @setState(isClient: true)

  fallbackStyles: ()-> (
    <style type='text/css'>{'''
      .ui-dropdown .dropdown-toggle { padding-bottom: 7px }
      .dropdown:hover .dropdown-menu { display: block }
  '''}</style>)

  render: ({props, state} = this)->
    unless props.children.props.bsRole == 'menu'
      throw new Error('Missing or invalid Menu!')

    id = props.id || "#{this.props.toggle}_menu"

    <Dropdown id={id} className={ui.cx(props.mods, 'ui-dropdown dropdown')} data-test-id={@props.testId}>

      {if !state.isClient then @fallbackStyles()}

      <Dropdown.Toggle
        componentClass={Link}
        bsClass='dropdown-toggle ui-drop-toggle'
        {...props.toggleProps}>
        {props.toggle}
        <Icon i='arrow-down stand-alone small'/>
      </Dropdown.Toggle>

      {props.children}

    </Dropdown>

UIDropdown.Menu = Dropdown.Menu
UIDropdown.MenuItem = (props = @props)->
  hasLink = f.present(props.href) || f.present(props.onClick)
  isDisabled = if f.present(props.disabled) then props.disabled else !hasLink
  <MenuItem componentClass={Link} className="ui-drop-item" disabled={isDisabled}
    {...props}/>
module.exports = UIDropdown
