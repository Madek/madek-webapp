# Very minimal Dropdown, with pure-CSS fallback,
# receives toggle content via prop and menu as children.

# It's only responsible for toggling the menu via JS or CSS.

# NOTE: before implementing a more flexible version,
#       check if we could just port (and style!) from boostrap…
#       <https://github.com/react-bootstrap/react-bootstrap>

React = require('react')
PropTypes = React.PropTypes
ui = require('../lib/ui.coffee')

Icon = require('./Icon.cjsx')

MODS = ['stick-right'] # TODO: check and validate supported mods

module.exports = React.createClass
  displayName: 'UI.Dropdown'
  propTypes:
    toggle: PropTypes.node.isRequired
    toggleProps: PropTypes.object
    children: PropTypes.node.isRequired
    startOpen: PropTypes.bool

  getInitialState: ()-> {isClient: false, isOpen: @props.startOpen}
  componentDidMount: ()-> @setState(isClient: true)
  _onMenuOpen: ()-> @setState(isOpen: true)
  _onMenuClose: ()-> @setState(isOpen: false)

  getDefaultProps: ()->
    startOpen: false,
    fallbackStyles: ()-> (
      <style type="text/css">{'''
        .ui-dropdown .ui-drop-toggle { padding-bottom: 7px }
        .dropdown:hover .dropdown-menu { display: block }
    '''}</style>)

  render: ({props, state} = this)->

    wrapperClasses = ui.cx(
      ui.parseMods(@props),
      {'open': @state.isOpen}
      'ui-dropdown dropdown') # TODO: fix styles, only ui-dropdown as base class

    <div className={wrapperClasses}>

      {if !state.isClient then props.fallbackStyles()}

      <a className="dropdown-toggle ui-drop-toggle"
        onClick={if @state.isOpen then @_onMenuClose else @_onMenuOpen}
        {...props.toggleProps}>
        {props.toggle} <Icon i="arrow-down stand-alone small"></Icon>
      </a>

      {# NOTE: old style set from js plugin: style="top: 100%; bottom: auto;"}
      {props.children}
    </div>
