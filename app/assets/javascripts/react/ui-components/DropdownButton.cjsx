React = require('react')
f = require('active-lodash')
cx = require('classnames')

Link = require('./Link.cjsx')
Icon = require('./Icon.cjsx')
Button = require('./Button.cjsx')

module.exports = React.createClass
  displayName: 'DropdownButton'
  propTypes:
    button: React.PropTypes.shape(
      children: React.PropTypes.node.isRequired
      # all other button props are optional
    ).isRequired
    dropdownMenu: React.PropTypes.node

  # FIXME: client-side only! css?
  getInitialState: ()->
    isClient: true
    showDropdown: false

  _onDropdowToggle: (event)->
    event.preventDefault()
    @setState(showDropdown: !@state.showDropdown)

  render: ({button, dropdownMenu, mods} = @props, {showDropdown} = @state)->
    btn =
      # from props
      children: button.children
      # from here
      onClick: @_onDropdowToggle
      mods: [@props.mods].concat(['dropdown-toggle', 'ui-drop-toggle'])
    btnProps = f.omit(btn, 'children')

    <div className={cx({'dropdown open': showDropdown}, mods, 'ui-dropdown')}>
      <Button {...btnProps}>
        {btn.children} <Icon i='arrow-down'
                          mods={'stand-alone ' + (!dropdownMenu && 'mid')}/>
      </Button>

      {dropdownMenu if showDropdown && dropdownMenu}

    </div>
